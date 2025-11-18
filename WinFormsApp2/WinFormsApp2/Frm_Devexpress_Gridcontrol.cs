//using DevExpress.DataProcessing;
//using DevExpress.Mvvm.POCO;
using DevExpress.Utils;
//using DevExpress.Xpo.Helpers;
using DevExpress.XtraEditors;
using DevExpress.XtraEditors.Repository;
//using DevExpress.XtraGantt.Scheduling;
//using DevExpress.XtraGrid;
//using DevExpress.XtraGrid.Columns;
using DevExpress.XtraGrid.Views.Grid;
//using DevExpress.XtraGrid.Views.Grid.ViewInfo;
//using DevExpress.XtraRichEdit.Import.Doc;
//using DevExpress.XtraRichEdit.Model;
//using System;
using System.Collections;
//using System.Collections.Generic;
//using System.ComponentModel;
using System.Data;
//using System.Drawing;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;
//using System.Windows.Controls;
//using System.Windows.Forms;
//using static SpreadsheetGear.Commands.CommandRange;
//using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace WinFormsApp2
{
    public partial class Frm_Devexpress_Gridcontrol : XtraForm//Form
    {
        //conn cls_sys = new Cls_BaseSys();
        //Datat Table
        public static DataTable dt_month_list = new DataTable();
        public static DataTable dt_Signature_List = new DataTable();
        public static DataTable dt_HERO_list = new DataTable();
        public static DataTable dt_Category_list = new DataTable();
        public static DataTable dt_Sub_Category_list = new DataTable();
        public static DataTable dt_Group_Class_list = new DataTable();
        public static DataTable dt_Filter_Header = new DataTable();
        public static DataTable dt_Filter_Detail = new DataTable();
        public static DataTable dt_Filter_Summary = new DataTable();

        public static DataTable dt_name_detail = new DataTable();
        public static DataSet Ds = new DataSet();
        public static string sp_name = "sp_get_Filter_GAP_DPvsBP";

        public static string Type_A = "";//Unit/Value/Percent
        public static string Type_ABS = "";
        public static string Type_A_Condition = "";//>=,<=,<>,=,>,<....
        public static string Type_A_Value = "0"; //giá trị cần lọc

        public static string Type_B_Channel = "";//Channel ONLINE/OFFLINE/O+O
        public static string Type_E_MaterialType = "";//material type: YFG, YSM2, PLV
        public static string Type_C_Period = "";//Period: Months.....
        public static string Type_D_Signature = "";//master: Signature/HERO/Category/Sub-Category,Group-Class
        public static string Type_D_HERO = "";//master: Signature/HERO/Category/Sub-Category,Group-Class
        public static string Type_D_Category = "";//master: Signature/HERO/Category/Sub-Category,Group-Class
        public static string Type_D_Sub_Category = "";//master: Signature/HERO/Category/Sub-Category,Group-Class
        public static string Type_D_Group_Class = "";//master: Signature/HERO/Category/Sub-Category,Group-Class

        public static string Method_cal = "INDIVIDUAL";//Individual/Summary
        public static string List_Signature = "";
        public static string List_HERO = "";
        public static string List_Category = "";
        public static string List_Sub_Category = "";
        public static string List_Group_Class = "";

        public static int Totalmonths = 0;
        public static int Currentrow = 0;
        public static int Year_FC = 0;
        public static int Month_FC = 0;//=Currentrow+1
        public static int Year_Quaterly = 0;
        public static int _currentrow_header = -1;
        public static int _currentrow_detail = -1;
        public static string _forecastingLine = string.Empty;
        public static string _Channel = string.Empty;

        public static bool _select_All = false;

        public Frm_Devexpress_Gridcontrol(string _division, string _fm_key)
        {
            InitializeComponent();
            Totalmonths = 12 - int.Parse(Connection_SQL._fmkey.Substring(4, 2)) + 1;
            Currentrow = int.Parse(Connection_SQL._fmkey.Substring(4, 2)) - 1;
            Year_FC = int.Parse(Connection_SQL._fmkey.Substring(0, 4));
            Month_FC = Currentrow + 1;
            //create month list
            Create_Month_List_Ini(_select_All);
            //push month list into datagridview
            //get_Motnh_Datagridview();
            //get master data from WF   
            Create_Master_Data_WF();
            //push dataatble tinto control gridlookupedit
            push_master_Into_Control();
            GrpReport.SendToBack();
            GrpFilter.BringToFront();
            GrpFilter.Dock = DockStyle.Fill;
            GrpFilter.Text = GrpFilter.Text + " Server name:" + Connection_SQL._serverName + " Database Name: " + Connection_SQL._DatabaseName;
        }
        private void Frm_Devexpress_Gridcontrol_Load(object sender, EventArgs e)
        {

            ra_Individual.Checked = true;
            Year_Quaterly = Year_FC;
            chkSelectAllMonths.Checked = true;
            Load_list_compare();
            DataGridview_Readonly_Cell();
            set_quaterly_readonly();
            Signature_Select_All(true);
            HERO_SELECT_ALL(true);
            CATEGORY_SELECT_ALL(true);
            SUB_CATEGORY_SELECT_ALL(true);
            GROUP_CLASS_SELECT_ALL(true);
            //MessageBox.Show("Haha");
        }
        //void Create_GridDetail()
        //{
        //    //tạo dataset-cấu hình gridcontrol
        //    cls_function.Create_Dataset_New5V
        //    (
        //          Ds//dataset
        //        , dt_name_detail//datatable
        //        , sp_name//tên sp
        //        , gridControl2//gridcontrol chưa datatable/datase
        //        , gridView2//grdiview thuộc gridcontrol
        //        , NewItemRowPosition.None
        //        , EditorShowMode.Default
        //    );
        //}
        void Load_grid_Detail(string List_forecastingline)
        {
            int _show_all_channel = 0;
            if (chkShowAll_Channel.Checked)
            {
                _show_all_channel = 1;
            }

            string Forecastingline_ok = "";
            if (List_forecastingline.Length > 0)
            {
                Forecastingline_ok = List_forecastingline;
            }
            else
            {
                Forecastingline_ok = _forecastingLine + "**" + _Channel;
            }

            //get detail
            ArrayList array_p1 = new ArrayList()
            {
                "@Division",
                "@FM_KEY",
                "@Channel",
                "@Header",
                "@ListColumn",
                "@Subgrp",
                "@ShowAll_Channel"
            };
            ArrayList array_v1 = new ArrayList()
            {
                Connection_SQL._division,
                Connection_SQL._fmkey,
                Type_B_Channel,
                "D",//Header/Detail/Summarry
                "",//@ListColumn
                Forecastingline_ok,//SUbgrp
                _show_all_channel
            };
            dt_Filter_Detail = null;
            dt_Filter_Detail = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_get_Filter_GAP_DPvsBP", array_p1, array_v1);
            gridControl2.DataSource = null;
            gridControl2.DataSource = dt_Filter_Detail;
            gridControl2.ForceInitialize();
            gridView2.RowCellStyle += new RowCellStyleEventHandler(gridView2_RowCellStyle);
            gridView2.OptionsBehavior.Editable = true;
            gridView2.OptionsView.ColumnAutoWidth = false;
            gridView2.OptionsView.BestFitMaxRowCount = -1;
            gridView2.OptionsBehavior.EditingMode = DevExpress.XtraGrid.Views.Grid.GridEditingMode.Inplace;
            gridView2.OptionsBehavior.EditorShowMode = EditorShowMode.MouseDownFocused;//EditorShowMode.MouseDownFocused;
            gridView2.Columns["ID"].Visible = false;
            gridView2.BestFitColumns();
            //expand group
            gridView2.ExpandAllGroups();
            //Định dạng số
            format_gridview2();
            this.gridView2.Columns["Forecasting Line"].Group();
            //gridView2.GroupSummary.Add(new GridGroupSummaryItem()
            //{
            //    FieldName = "Forecasting Line"
            //});

        }
        void load_Grid_Summary()
        {
            //get detail
            ArrayList array_p1 = new ArrayList()
            {
                "@Division",
                "@FM_KEY",
                "@Channel",
                "@Header",
                "@ListColumn",
                "@Subgrp",
                "@ShowAll_Channel"
            };
            ArrayList array_v1 = new ArrayList()
            {
                Connection_SQL._division,
                Connection_SQL._fmkey,
                Type_B_Channel,
                "S",//Header
                Type_C_Period,//List column
                "",
                0//Subgrp
            };
            dt_Filter_Summary = null;
            dt_Filter_Summary = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_get_Filter_GAP_DPvsBP", array_p1, array_v1);
            gridControl3.DataSource = dt_Filter_Summary;
            gridControl3.ForceInitialize();
            gridView3.OptionsBehavior.Editable = false;
            gridView3.OptionsBehavior.ReadOnly = true;
            gridView3.OptionsView.ColumnAutoWidth = false;
            gridView3.OptionsView.BestFitMaxRowCount = -1;
            gridView3.OptionsBehavior.EditingMode = DevExpress.XtraGrid.Views.Grid.GridEditingMode.Inplace;
            gridView3.OptionsBehavior.EditorShowMode = EditorShowMode.MouseDownFocused;//EditorShowMode.MouseDownFocused;
            gridView3.BestFitColumns();
        }
        void Create_Master_Data_WF()
        {
            dt_Signature_List = Connection_SQL.GetDataTable(@"select DISTINCT [Signature] from FC_FM_Original_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + " where isnull([Signature],'')<>'' ");
            dt_HERO_list = Connection_SQL.GetDataTable(@"select DISTINCT HERO from FC_FM_Original_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + " where isnull(HERO,'')<>'' ");
            dt_Category_list = Connection_SQL.GetDataTable(@"select DISTINCT [CAT/Axe] from FC_FM_Original_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + " where isnull([CAT/Axe],'')<>''");
            dt_Sub_Category_list = Connection_SQL.GetDataTable(@"select DISTINCT [SUB CAT/ Sub Axe] from FC_FM_Original_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + " where isnull([SUB CAT/ Sub Axe],'')<>'' ");
            dt_Group_Class_list = Connection_SQL.GetDataTable(@"select DISTINCT [GROUP/ Class] from FC_FM_Original_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + " where isnull([GROUP/ Class],'')<>'' ");
        }
        CheckBox headerCheckBox_Signature = new CheckBox();
        void Create_DG_Signature_Checkkbox()
        {
            DG_Signature.DataSource = dt_Signature_List;
            DG_Signature.AllowUserToAddRows = false;
            DG_Signature.MultiSelect = true;
            // DG_Signature.Columns[0].Width = 200; // Removed - using AutoSizeColumnsMode instead

            Point headercelllocation = DG_Signature.GetCellDisplayRectangle(0, -1, true).Location;
            headerCheckBox_Signature.Location = new Point(headercelllocation.X + 50, headercelllocation.Y + 2);
            headerCheckBox_Signature.BackColor = Color.White;
            headerCheckBox_Signature.Size = new Size(18, 18);
            headerCheckBox_Signature.Click += new EventHandler(HeaderCheckBox_DG_Signature_Clicked);
            DG_Signature.Controls.Add(headerCheckBox_Signature);

            //Add a CheckBox Column to the DataGridView at the first position.
            DataGridViewCheckBoxColumn checkBoxColumn = new DataGridViewCheckBoxColumn();
            checkBoxColumn.HeaderText = "";
            checkBoxColumn.Width = 30;
            checkBoxColumn.Name = "checkBoxColumn";
            DG_Signature.Columns.Insert(0, checkBoxColumn);

            //Assign Click event to the DataGridView Cell.
            DG_Signature.CellContentClick += new DataGridViewCellEventHandler(DG_Signature_CellClick);
            DG_Signature.EndEdit();
            //Loop and check and uncheck all row CheckBoxes based on Header Cell CheckBox.
            foreach (DataGridViewRow row in DG_Signature.Rows)
            {
                DataGridViewCheckBoxCell checkBox = (row.Cells["checkBoxColumn"] as DataGridViewCheckBoxCell);
                checkBox.Value = headerCheckBox_Signature.Checked;
            }
        }
        void HeaderCheckBox_DG_Signature_Clicked(object sender, EventArgs e)//,DataGridView dgv1)
        {
            //Necessary to end the edit mode of the Cell.
            Signature_Select_All(false);
        }
        void Signature_Select_All(bool _checked)
        {
            DG_Signature.EndEdit();
            //Loop and check and uncheck all row CheckBoxes based on Header Cell CheckBox.
            foreach (DataGridViewRow row in DG_Signature.Rows)
            {
                DataGridViewCheckBoxCell checkBox = (row.Cells["checkBoxColumn"] as DataGridViewCheckBoxCell);
                checkBox.Value = (_checked) ? _checked : headerCheckBox_Signature.Checked;
            }
        }
        private void DG_Signature_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //Check to ensure that the row CheckBox is clicked.
            if (e.RowIndex >= 0 && e.ColumnIndex == 0)
            {
                //Loop to verify whether all row CheckBoxes are checked or not.
                bool isChecked = true;
                foreach (DataGridViewRow row in DG_Signature.Rows)
                {
                    if (Convert.ToBoolean(row.Cells["checkBoxColumn"].EditedFormattedValue) == false)
                    {
                        isChecked = false;
                        break;
                    }
                }
                headerCheckBox_Signature.Checked = isChecked;
            }
        }
        CheckBox headerCheckBox_Hero = new CheckBox();
        void Create_DG_HERO_Checkkbox()
        {
            DG_HERO.DataSource = dt_HERO_list;
            DG_HERO.AllowUserToAddRows = false;
            DG_HERO.MultiSelect = true;
            // DG_HERO.Columns[0].Width = 200; // Removed - using AutoSizeColumnsMode instead

            Point headercelllocation = DG_HERO.GetCellDisplayRectangle(0, -1, true).Location;
            headerCheckBox_Hero.Location = new Point(headercelllocation.X + 50, headercelllocation.Y + 2);
            headerCheckBox_Hero.BackColor = Color.White;
            headerCheckBox_Hero.Size = new Size(18, 18);
            headerCheckBox_Hero.Click += new EventHandler(HeaderCheckBox_DG_HERO_Clicked);
            DG_HERO.Controls.Add(headerCheckBox_Hero);

            //Add a CheckBox Column to the DataGridView at the first position.
            DataGridViewCheckBoxColumn checkBoxColumn = new DataGridViewCheckBoxColumn();
            checkBoxColumn.HeaderText = "";
            checkBoxColumn.Width = 30;
            checkBoxColumn.Name = "checkBoxColumn";
            DG_HERO.Columns.Insert(0, checkBoxColumn);

            //Assign Click event to the DataGridView Cell.
            DG_HERO.CellContentClick += new DataGridViewCellEventHandler(DG_HERO_CellClick);
        }
        void HeaderCheckBox_DG_HERO_Clicked(object sender, EventArgs e)//,DataGridView dgv1)
        {
            //Necessary to end the edit mode of the Cell.
            HERO_SELECT_ALL(false);
        }
        void HERO_SELECT_ALL(bool _checked)
        {
            DG_HERO.EndEdit();
            //Loop and check and uncheck all row CheckBoxes based on Header Cell CheckBox.
            foreach (DataGridViewRow row in DG_HERO.Rows)
            {
                DataGridViewCheckBoxCell checkBox = (row.Cells["checkBoxColumn"] as DataGridViewCheckBoxCell);
                checkBox.Value = (_checked) ? _checked : headerCheckBox_Hero.Checked;
            }
        }
        private void DG_HERO_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //Check to ensure that the row CheckBox is clicked.
            if (e.RowIndex >= 0 && e.ColumnIndex == 0)
            {
                //Loop to verify whether all row CheckBoxes are checked or not.
                bool isChecked = true;
                foreach (DataGridViewRow row in DG_HERO.Rows)
                {
                    if (Convert.ToBoolean(row.Cells["checkBoxColumn"].EditedFormattedValue) == false)
                    {
                        isChecked = false;
                        break;
                    }
                }
                headerCheckBox_Hero.Checked = isChecked;
            }
        }
        CheckBox headerCheckBox_Category = new CheckBox();
        void Create_DG_CATEGORY_Checkkbox()
        {
            DG_Category.DataSource = dt_Category_list;
            DG_Category.AllowUserToAddRows = false;
            DG_Category.MultiSelect = true;
            // DG_Category.Columns[0].Width = 200; // Removed - using AutoSizeColumnsMode instead

            Point headercelllocation = DG_Category.GetCellDisplayRectangle(0, -1, true).Location;
            headerCheckBox_Category.Location = new Point(headercelllocation.X + 50, headercelllocation.Y + 2);
            headerCheckBox_Category.BackColor = Color.White;
            headerCheckBox_Category.Size = new Size(18, 18);
            headerCheckBox_Category.Click += new EventHandler(HeaderCheckBox_DG_CATEGORY_Clicked);
            DG_Category.Controls.Add(headerCheckBox_Category);

            //Add a CheckBox Column to the DataGridView at the first position.
            DataGridViewCheckBoxColumn checkBoxColumn = new DataGridViewCheckBoxColumn();
            checkBoxColumn.HeaderText = "";
            checkBoxColumn.Width = 30;
            checkBoxColumn.Name = "checkBoxColumn";
            DG_Category.Columns.Insert(0, checkBoxColumn);

            //Assign Click event to the DataGridView Cell.
            DG_Category.CellContentClick += new DataGridViewCellEventHandler(DG_CATEGORY_CellClick);
        }
        void HeaderCheckBox_DG_CATEGORY_Clicked(object sender, EventArgs e)//,DataGridView dgv1)
        {
            //Necessary to end the edit mode of the Cell.
            CATEGORY_SELECT_ALL(false);
        }
        void CATEGORY_SELECT_ALL(bool _checked)
        {
            DG_Category.EndEdit();
            //Loop and check and uncheck all row CheckBoxes based on Header Cell CheckBox.
            foreach (DataGridViewRow row in DG_Category.Rows)
            {
                DataGridViewCheckBoxCell checkBox = (row.Cells["checkBoxColumn"] as DataGridViewCheckBoxCell);
                checkBox.Value = (_checked) ? _checked : headerCheckBox_Category.Checked;
            }
        }
        private void DG_CATEGORY_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //Check to ensure that the row CheckBox is clicked.
            if (e.RowIndex >= 0 && e.ColumnIndex == 0)
            {
                //Loop to verify whether all row CheckBoxes are checked or not.
                bool isChecked = true;
                foreach (DataGridViewRow row in DG_Category.Rows)
                {
                    if (Convert.ToBoolean(row.Cells["checkBoxColumn"].EditedFormattedValue) == false)
                    {
                        isChecked = false;
                        break;
                    }
                }
                headerCheckBox_Category.Checked = isChecked;
            }
        }
        CheckBox headerCheckBox_Sub_Category = new CheckBox();
        void Create_DG_SUB_CATEGORY_Checkkbox()
        {
            DG_Sub_Category.DataSource = dt_Sub_Category_list;
            DG_Sub_Category.AllowUserToAddRows = false;
            DG_Sub_Category.MultiSelect = true;
            // DG_Sub_Category.Columns[0].Width = 200; // Removed - using AutoSizeColumnsMode instead

            Point headercelllocation = DG_Sub_Category.GetCellDisplayRectangle(0, -1, true).Location;
            headerCheckBox_Sub_Category.Location = new Point(headercelllocation.X + 50, headercelllocation.Y + 2);
            headerCheckBox_Sub_Category.BackColor = Color.White;
            headerCheckBox_Sub_Category.Size = new Size(18, 18);
            headerCheckBox_Sub_Category.Click += new EventHandler(HeaderCheckBox_DG_SUB_CATEGORY_Clicked);
            DG_Sub_Category.Controls.Add(headerCheckBox_Sub_Category);

            //Add a CheckBox Column to the DataGridView at the first position.
            DataGridViewCheckBoxColumn checkBoxColumn = new DataGridViewCheckBoxColumn();
            checkBoxColumn.HeaderText = "";
            checkBoxColumn.Width = 30;
            checkBoxColumn.Name = "checkBoxColumn";
            DG_Sub_Category.Columns.Insert(0, checkBoxColumn);

            //Assign Click event to the DataGridView Cell.
            DG_Sub_Category.CellContentClick += new DataGridViewCellEventHandler(DG_SUB_CATEGORY_CellClick);
        }
        void HeaderCheckBox_DG_SUB_CATEGORY_Clicked(object sender, EventArgs e)//,DataGridView dgv1)
        {
            //Necessary to end the edit mode of the Cell.
            SUB_CATEGORY_SELECT_ALL(false);
        }
        void SUB_CATEGORY_SELECT_ALL(bool _checked)
        {
            DG_Sub_Category.EndEdit();
            //Loop and check and uncheck all row CheckBoxes based on Header Cell CheckBox.
            foreach (DataGridViewRow row in DG_Sub_Category.Rows)
            {
                DataGridViewCheckBoxCell checkBox = (row.Cells["checkBoxColumn"] as DataGridViewCheckBoxCell);
                checkBox.Value = (_checked) ? _checked : headerCheckBox_Sub_Category.Checked;
            }
        }
        private void DG_SUB_CATEGORY_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //Check to ensure that the row CheckBox is clicked.
            if (e.RowIndex >= 0 && e.ColumnIndex == 0)
            {
                //Loop to verify whether all row CheckBoxes are checked or not.
                bool isChecked = true;
                foreach (DataGridViewRow row in DG_Sub_Category.Rows)
                {
                    if (Convert.ToBoolean(row.Cells["checkBoxColumn"].EditedFormattedValue) == false)
                    {
                        isChecked = false;
                        break;
                    }
                }
                headerCheckBox_Sub_Category.Checked = isChecked;
            }
        }
        CheckBox headerCheckBox_Group_Class = new CheckBox();
        void Create_DG_GROUP_CLASS_Checkkbox()
        {
            DG_GROUP_CLASS.DataSource = dt_Group_Class_list;
            DG_GROUP_CLASS.AllowUserToAddRows = false;
            DG_GROUP_CLASS.MultiSelect = true;
            // DG_GROUP_CLASS.Columns[0].Width = 200; // Removed - using AutoSizeColumnsMode instead

            Point headercelllocation = DG_GROUP_CLASS.GetCellDisplayRectangle(0, -1, true).Location;
            headerCheckBox_Group_Class.Location = new Point(headercelllocation.X + 50, headercelllocation.Y + 2);
            headerCheckBox_Group_Class.BackColor = Color.White;
            headerCheckBox_Group_Class.Size = new Size(18, 18);
            headerCheckBox_Group_Class.Click += new EventHandler(HeaderCheckBox_DG_GROUP_CLASS_Clicked);
            DG_GROUP_CLASS.Controls.Add(headerCheckBox_Group_Class);

            //Add a CheckBox Column to the DataGridView at the first position.
            DataGridViewCheckBoxColumn checkBoxColumn = new DataGridViewCheckBoxColumn();
            checkBoxColumn.HeaderText = "";
            checkBoxColumn.Width = 30;
            checkBoxColumn.Name = "checkBoxColumn";
            DG_GROUP_CLASS.Columns.Insert(0, checkBoxColumn);

            //Assign Click event to the DataGridView Cell.
            DG_GROUP_CLASS.CellContentClick += new DataGridViewCellEventHandler(DG_GROUP_CLASS_CellClick);
        }
        void HeaderCheckBox_DG_GROUP_CLASS_Clicked(object sender, EventArgs e)//,DataGridView dgv1)
        {
            //Necessary to end the edit mode of the Cell.
            GROUP_CLASS_SELECT_ALL(false);
        }
        void GROUP_CLASS_SELECT_ALL(bool _checked)
        {
            DG_GROUP_CLASS.EndEdit();
            //Loop and check and uncheck all row CheckBoxes based on Header Cell CheckBox.
            foreach (DataGridViewRow row in DG_GROUP_CLASS.Rows)
            {
                DataGridViewCheckBoxCell checkBox = (row.Cells["checkBoxColumn"] as DataGridViewCheckBoxCell);
                checkBox.Value = (_checked) ? _checked : headerCheckBox_Group_Class.Checked;
            }
        }
        private void DG_GROUP_CLASS_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //Check to ensure that the row CheckBox is clicked.
            if (e.RowIndex >= 0 && e.ColumnIndex == 0)
            {
                //Loop to verify whether all row CheckBoxes are checked or not.
                bool isChecked = true;
                foreach (DataGridViewRow row in DG_GROUP_CLASS.Rows)
                {
                    if (Convert.ToBoolean(row.Cells["checkBoxColumn"].EditedFormattedValue) == false)
                    {
                        isChecked = false;
                        break;
                    }
                }
                headerCheckBox_Group_Class.Checked = isChecked;
            }
        }

        void push_master_Into_Control()
        {
            Create_DG_Signature_Checkkbox();
            Create_DG_HERO_Checkkbox();
            Create_DG_CATEGORY_Checkkbox();
            Create_DG_SUB_CATEGORY_Checkkbox();
            Create_DG_GROUP_CLASS_Checkkbox();

            // Adjust SplitterDistance dynamically after DataGridViews are populated
            AdjustSplitterDistances();
        }

        void AdjustSplitterDistances()
        {
            // Calculate the preferred width for each DataGridView based on its columns
            int GetPreferredWidth(DataGridView dgv)
            {
                int width = 0;
                foreach (DataGridViewColumn col in dgv.Columns)
                {
                    width += col.Width;
                }
                // Add padding for borders and scrollbar
                width += dgv.RowHeadersWidth + SystemInformation.VerticalScrollBarWidth + 5;
                return width;
            }

            // Adjust splitContainer1 (DG_Signature)
            int signatureWidth = GetPreferredWidth(DG_Signature);
            if (signatureWidth > 50 && signatureWidth < splitContainer1.Width - 100)
            {
                splitContainer1.SplitterDistance = signatureWidth;
            }

            // Adjust splitContainer2 (DG_HERO)
            int heroWidth = GetPreferredWidth(DG_HERO);
            if (heroWidth > 50 && heroWidth < splitContainer2.Width - 100)
            {
                splitContainer2.SplitterDistance = heroWidth;
            }

            // Adjust splitContainer3 (DG_Category)
            int categoryWidth = GetPreferredWidth(DG_Category);
            if (categoryWidth > 50 && categoryWidth < splitContainer3.Width - 100)
            {
                splitContainer3.SplitterDistance = categoryWidth;
            }

            // Adjust splitContainer4 (DG_Sub_Category)
            int subCategoryWidth = GetPreferredWidth(DG_Sub_Category);
            if (subCategoryWidth > 50 && subCategoryWidth < splitContainer4.Width - 100)
            {
                splitContainer4.SplitterDistance = subCategoryWidth;
            }
        }

        void Create_Month_List_Ini(bool _selectAll)
        {
            dt_month_list = new DataTable();
            //define column
            dt_month_list.Columns.Add("M1", typeof(bool));
            dt_month_list.Columns.Add("M2", typeof(bool));
            dt_month_list.Columns.Add("M3", typeof(bool));
            dt_month_list.Columns.Add("M4", typeof(bool));
            dt_month_list.Columns.Add("M5", typeof(bool));
            dt_month_list.Columns.Add("M6", typeof(bool));
            dt_month_list.Columns.Add("M7", typeof(bool));
            dt_month_list.Columns.Add("M8", typeof(bool));
            dt_month_list.Columns.Add("M9", typeof(bool));
            dt_month_list.Columns.Add("M10", typeof(bool));
            dt_month_list.Columns.Add("M11", typeof(bool));
            dt_month_list.Columns.Add("M12", typeof(bool));

            //set value
            if (_selectAll == true)
            {
                dt_month_list.Rows.Add(true, true, true, true, true, true, true, true, true, true, true, true);
            }
            else
            {
                dt_month_list.Rows.Add(false, false, false, false, false, false, false, false, false, false, false, false);
            }
            dataGridView1.DataSource = dt_month_list;
            dataGridView1.AllowUserToAddRows = false;
            dataGridView1.Columns[0].Width = 40;
            dataGridView1.Columns[1].Width = 40;
            dataGridView1.Columns[2].Width = 40;
            dataGridView1.Columns[3].Width = 40;
            dataGridView1.Columns[4].Width = 40;
            dataGridView1.Columns[5].Width = 40;
            dataGridView1.Columns[6].Width = 40;
            dataGridView1.Columns[7].Width = 40;
            dataGridView1.Columns[8].Width = 40;
            dataGridView1.Columns[9].Width = 40;
            dataGridView1.Columns[10].Width = 40;
            dataGridView1.Columns[11].Width = 40;
        }
        void get_Motnh_Datagridview(bool select_all)
        {
            if (Year_FC == Year_Quaterly)
            {
                for (int i = 0; i < 12; i++)
                {
                    if (i < Currentrow)
                    {
                        dataGridView1.Rows[0].Cells[i].Value = false;
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = select_all;
                    }
                }
            }
            else
            {
                for (int i = 0; i < 12; i++)
                {
                    dataGridView1.Rows[0].Cells[i].Value = select_all;
                }
            }
            DataGridview_Readonly_Cell();
        }
        void set_quaterly_readonly()
        {
            if (Currentrow > 3)
            {
                if (Year_FC == DateTime.Now.Year)
                {
                    ra_Y0_Q1.Enabled = false;
                }
                else
                {
                    ra_Y1_Q1.Enabled = false;
                }
            }
            if (Currentrow > 6)
            {
                if (Year_FC == DateTime.Now.Year)
                {
                    ra_Y0_Q2.Enabled = false;
                }
                else
                {
                    ra_Y1_Q2.Enabled = false;
                }
            }
            if (Currentrow > 9)
            {
                if (Year_FC == DateTime.Now.Year)
                {
                    ra_Y0_Q3.Enabled = false;
                }
                else
                {
                    ra_Y1_Q3.Enabled = false;
                }
            }
            if (Currentrow > 12)
            {
                if (Year_FC == DateTime.Now.Year)
                {
                    ra_Y0_Q4.Enabled = false;
                }
                else
                {
                    ra_Y1_Q4.Enabled = false;
                }
            }
        }
        private void gridControl1_Click(object sender, EventArgs e)
        {
        }
        void Load_list_compare()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Compare list", typeof(string));
            dt.Rows.Add("=");
            dt.Rows.Add("<>");
            dt.Rows.Add(">");
            dt.Rows.Add(">=");
            dt.Rows.Add("<");
            dt.Rows.Add("<=");

            GLCompareList.Properties.DataSource = dt;
            GLCompareList.Properties.DisplayMember = "Compare list";
            GLCompareList.Properties.ValueMember = "Compare list";
            //GLCompareList.Properties.TextEditStyle = DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor;
            GLCompareList.Properties.TextEditStyle = DevExpress.XtraEditors.Controls.TextEditStyles.Standard;
            GLCompareList.EditValue = "=";
            GLCompareList.Properties.TextEditStyle = DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor;
        }
        
        private void cmdY0_Click(object sender, EventArgs e)
        {
            //cmdY0.Appearance.BackColor = Color.FromArgb(192, 255, 192);
            //cmdY1.Appearance.BackColor = Color.FromArgb(255, 224, 192);
        }

        private void cmdY1_Click(object sender, EventArgs e)
        {
            //cmdY1.Appearance.BackColor = Color.FromArgb(192, 255, 192);
            //cmdY0.Appearance.BackColor = Color.FromArgb(255, 224, 192);
        }

        private void cmdQ1_Click(object sender, EventArgs e)
        {
            //cmdQ1.Appearance.BackColor = Color.FromArgb(192, 255, 192);
        }

        private void chkSelectAllMonths_CheckedChanged(object sender, EventArgs e)
        {

        }

        void Fill_months_Quaterly()
        {
            LbError.Text = "";
            //clear list month to false
            for (int i = 0; i < 12; i++)
            {
                dataGridView1.Rows[0].Cells[i].Value = false;
            }

            //check đang chọn quaterly = true
            //bool quaterly_checked = false;
            if (ra_Y0_Q1.Checked || ra_Y0_Q2.Checked || ra_Y0_Q3.Checked || ra_Y0_Q4.Checked || ra_ALL_Y0.Checked
                || ra_Y1_Q1.Checked || ra_Y1_Q2.Checked || ra_Y1_Q3.Checked || ra_Y1_Q4.Checked || ra_ALL_Y1.Checked)
            {
                //quaterly_checked = true;
                chkSelectAllMonths.Checked = false;
                chkYTG.Checked = false;
            }
            if (ra_Y0_Q1.Checked)
            {
                Year_Quaterly = Year_FC;
                for (int i = 0; i < 3; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_Y1_Q1.Checked)
            {
                Year_Quaterly = Year_FC + 1;
                for (int i = 0; i < 3; i++)
                {

                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_Y0_Q2.Checked)
            {
                Year_Quaterly = Year_FC;
                for (int i = 3; i < 6; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_Y1_Q2.Checked)
            {
                Year_Quaterly = Year_FC + 1;
                for (int i = 3; i < 6; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_Y0_Q3.Checked)
            {
                Year_Quaterly = Year_FC;
                for (int i = 6; i < 9; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_Y1_Q3.Checked)
            {
                Year_Quaterly = Year_FC + 1;
                for (int i = 6; i < 9; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_Y0_Q4.Checked)
            {
                Year_Quaterly = Year_FC;
                for (int i = 9; i < 12; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_Y1_Q4.Checked)
            {
                Year_Quaterly = Year_FC + 1;
                for (int i = 9; i < 12; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_ALL_Y0.Checked)
            {
                Year_Quaterly = Year_FC;
                for (int i = 0; i < 12; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            else if (ra_ALL_Y1.Checked)
            {
                Year_Quaterly = Year_FC + 1;
                for (int i = 0; i < 12; i++)
                {
                    if (Year_FC == Year_Quaterly)
                    {
                        if (i >= Currentrow)
                        {
                            dataGridView1.Rows[0].Cells[i].Value = true;
                        }
                    }
                    else
                    {
                        dataGridView1.Rows[0].Cells[i].Value = true;
                    }
                }
            }
            dataGridView1.Focus();
        }
        void DataGridview_Readonly_Cell()
        {
            bool enabel = false;
            if (Year_FC == Year_Quaterly)
            {
                for (int i = 0; i < 12; i++)
                {
                    if (i < Currentrow)
                    {
                        enableCell(dataGridView1.Rows[0].Cells[i], enabel);
                    }
                }
            }
            else
            {
                for (int i = 0; i < 12; i++)
                {
                    enabel = true;
                    enableCell(dataGridView1.Rows[0].Cells[i], enabel);
                }
            }
        }
        void enableCell(DataGridViewCell dc, bool enabled)
        {
            //toggle read-only state
            dc.ReadOnly = !enabled;
            if (enabled)
            {
                //restore cell style to the default value
                dc.Style.BackColor = dc.OwningColumn.DefaultCellStyle.BackColor;
                dc.Style.ForeColor = dc.OwningColumn.DefaultCellStyle.ForeColor;
            }
            else
            {
                //gray out the cell
                dc.Style.BackColor = Color.LightGray;
                dc.Style.ForeColor = Color.DarkGray;
            }
        }

        void set_typeA_Value()
        {
            LbError.Text = "";
            Type_A = "";
            if (ra_Unit.Checked)
            {
                Type_A = "UNIT";
            }
            else if (ra_Value.Checked)
            {
                Type_A = "VALUE";
            }
            else if (ra_percent.Checked)
            {
                Type_A = "PERCENT";
            }

            //MessageBox.Show("T:"+Type_A+",C:"+cbbcomparelist.Text+"V:"+txtValue.Text);
        }
        void set_typeB_Channel()
        {
            LbError.Text = "";
            Type_B_Channel = "";
            if (chk_Online.Checked && chk_Offline.Checked && chk_OO.Checked)
            {
                Type_B_Channel = "ONLINE,OFFLINE,O+O";
            }
            else if (chk_Online.Checked == false && chk_Offline.Checked && chk_OO.Checked)
            {
                Type_B_Channel = "OFFLINE,O+O";
            }
            else if (chk_Online.Checked && chk_Offline.Checked == false && chk_OO.Checked)
            {
                Type_B_Channel = "ONLINE,O+O";
            }
            else if (chk_Online.Checked && chk_Offline.Checked && chk_OO.Checked == false)
            {
                Type_B_Channel = "ONLINE,OFFLINE";
            }
            else if (chk_Online.Checked)
            {
                Type_B_Channel = "ONLINE";
            }
            else if (chk_Offline.Checked)
            {
                Type_B_Channel = "OFFLINE";
            }
            else if (chk_OO.Checked)
            {
                Type_B_Channel = "O+O";
            }
            else
            {
                Type_B_Channel = "";
            }
            //MessageBox.Show(Type_B);
        }
        void set_typeE_MaterialType()
        {
            LbError.Text = "";
            Type_E_MaterialType = "";
            if (chk_MaterialType_YFG.Checked)
            {
                Type_E_MaterialType = "YFG";
            }
            if (chk_MaterialType_YSM2.Checked)
            {
                Type_E_MaterialType = Type_E_MaterialType + ",YSM2";
            }
            if (chk_MaterialType_PLV.Checked)
            {
                Type_E_MaterialType = Type_E_MaterialType + ",PLV";
            }
            //MessageBox.Show(Type_B);
        }
        void set_TypeC_Period()
        {
            LbError.Text = "";
            Type_C_Period = "";
            for (int i = 0; i < 12; i++)
            {

                if (Year_Quaterly == DateTime.Now.Year)
                {
                    //MessageBox.Show(dataGridView1.Rows[0].Cells[i].Value.ToString());
                    if ((i + 1) >= Month_FC)
                    {
                        if (bool.Parse(dataGridView1.Rows[0].Cells[i].Value.ToString()) == true)
                        {
                            if (Type_C_Period.Length == 0)
                            {
                                Type_C_Period = "Y0 (u) M" + (i + 1).ToString();
                            }
                            else
                            {
                                Type_C_Period = Type_C_Period + ",Y0 (u) M" + (i + 1).ToString();
                            }
                        }

                    }
                }
                else
                {
                    if (bool.Parse(dataGridView1.Rows[0].Cells[i].Value.ToString()) == true)
                    {
                        if (Type_C_Period.Length == 0)
                        {
                            Type_C_Period = "Y+1 (u) M" + (i + 1).ToString();
                        }
                        else
                        {
                            Type_C_Period = Type_C_Period + ",Y+1 (u) M" + (i + 1).ToString();
                        }
                    }
                }
            }
            //MessageBox.Show(Type_C_Period);
        }
        void Set_Method_Cal()
        {
            if (ra_Individual.Checked)
            {
                Method_cal = "INDIVIDUAL";
            }
            else if (ra_Summry.Checked)
            {
                Method_cal = "SUMMARY";
            }
            else
            {
                Method_cal = "";
            }
            //MessageBox.Show(Method_cal);
        }
        void Set_List_Signature()
        {
            List_Signature = "";
            int count_item = 0;
            // MessageBox.Show(DG_Signature.Rows.Count.ToString());
            try
            {
                for (int i = 0; i < DG_Signature.Rows.Count; i++)
                {
                    if (bool.Parse(DG_Signature.Rows[i].Cells[0].Value.ToString()) == true)
                    {
                        count_item = count_item + 1;
                        if (List_Signature.Length == 0)
                        {
                            List_Signature = DG_Signature.Rows[i].Cells[1].Value.ToString();
                        }
                        else
                        {
                            List_Signature = List_Signature + "," + DG_Signature.Rows[i].Cells[1].Value.ToString();
                        }
                    }
                }
            }
            catch
            {

            }
            if (DG_Signature.Rows.Count == count_item)
            {
                List_Signature = "ALL";
            }
            //MessageBox.Show(List_Signature);
        }
        void Set_List_HERO()
        {
            List_HERO = "";
            int count_item = 0;
            // MessageBox.Show(DG_Signature.Rows.Count.ToString());
            try
            {
                for (int i = 0; i < DG_HERO.Rows.Count; i++)
                {
                    if (bool.Parse(DG_HERO.Rows[i].Cells[0].Value.ToString()) == true)
                    {
                        count_item = count_item + 1;
                        if (List_HERO.Length == 0)
                        {
                            List_HERO = DG_HERO.Rows[i].Cells[1].Value.ToString();
                        }
                        else
                        {
                            List_HERO = List_HERO + "," + DG_HERO.Rows[i].Cells[1].Value.ToString();
                        }
                    }
                }
            }
            catch
            {

            }
            if (DG_HERO.Rows.Count == count_item)
            {
                List_HERO = "ALL";
            }
            //MessageBox.Show(List_HERO);
        }
        void Set_List_Category()
        {
            List_Category = "";
            int count_item = 0;
            // MessageBox.Show(DG_Signature.Rows.Count.ToString());
            try
            {
                for (int i = 0; i < DG_Category.Rows.Count; i++)
                {
                    if (bool.Parse(DG_Category.Rows[i].Cells[0].Value.ToString()) == true)
                    {
                        count_item = count_item + 1;
                        if (List_Category.Length == 0)
                        {
                            List_Category = DG_Category.Rows[i].Cells[1].Value.ToString();
                        }
                        else
                        {
                            List_Category = List_Category + "," + DG_Category.Rows[i].Cells[1].Value.ToString();
                        }
                    }
                }
            }
            catch
            {

            }
            if (DG_Category.Rows.Count == count_item)
            {
                List_Category = "ALL";
            }
            //MessageBox.Show(List_Category);
        }
        void Set_List_Sub_Category()
        {
            List_Sub_Category = "";
            int count_item = 0;
            // MessageBox.Show(DG_Signature.Rows.Count.ToString());
            try
            {
                for (int i = 0; i < DG_Sub_Category.Rows.Count; i++)
                {
                    if (bool.Parse(DG_Sub_Category.Rows[i].Cells[0].Value.ToString()) == true)
                    {
                        count_item = count_item + 1;
                        if (List_Sub_Category.Length == 0)
                        {
                            List_Sub_Category = DG_Sub_Category.Rows[i].Cells[1].Value.ToString();
                        }
                        else
                        {
                            List_Sub_Category = List_Sub_Category + "," + DG_Sub_Category.Rows[i].Cells[1].Value.ToString();
                        }
                    }
                }
            }
            catch
            {

            }
            if (DG_Sub_Category.Rows.Count == count_item)
            {
                List_Sub_Category = "ALL";
            }
            //MessageBox.Show(List_Sub_Category);
        }
        void Set_List_Group_Class()
        {
            List_Group_Class = "";
            int count_item = 0;
            // MessageBox.Show(DG_Signature.Rows.Count.ToString());
            try
            {
                for (int i = 0; i < DG_GROUP_CLASS.Rows.Count; i++)
                {
                    if (bool.Parse(DG_GROUP_CLASS.Rows[i].Cells[0].Value.ToString()) == true)
                    {
                        count_item = count_item + 1;
                        if (List_Group_Class.Length == 0)
                        {
                            List_Group_Class = DG_GROUP_CLASS.Rows[i].Cells[1].Value.ToString();
                        }
                        else
                        {
                            List_Group_Class = List_Group_Class + "," + DG_GROUP_CLASS.Rows[i].Cells[1].Value.ToString();
                        }
                    }
                }
            }
            catch
            {

            }
            if (DG_GROUP_CLASS.Rows.Count == count_item)
            {
                List_Group_Class = "ALL";
            }
            //MessageBox.Show(List_Group_Class);
        }
        void Get_Condition_List()
        {
            rConditionScript.Text = "";
            rConditionScript.Text = rConditionScript.Text +
                                        "\n"
                                        + " function [GAP]={" + ((Type_ABS == "1") ? "Allow" : "not Allow") + "}"
                                        + ", customer filter:={" + GLCompareList.Text + "}"
                                        + ", number filter:={" + txtValue.Text + "} " +
                                        "\n " +
                                        "Channel:={" + Type_B_Channel + "}" +
                                        "\n " +
                                        "Period:=" + " Method calculationL:={" + Method_cal
                                                    + "},\n Monthly selected:={" + Type_C_Period + "}" +
                                        "\n " +
                                        "Signature:=" + " {" + List_Signature + "}" +
                                        "\n " +
                                        "HERO:=" + " {" + List_HERO + "}" +
                                        "\n " +
                                        "Category:=" + " {" + List_Category + "}" +
                                        "\n " +
                                        "Sub-Category:=" + " {" + List_Sub_Category + "}" +
                                        "\n " +
                                        "Group-Class:=" + " {" + List_Group_Class + "}";
            /*
             Type_A,
                        Type_ABS,
                        cbbcomparelist.Text,
                        _compare_value,
                        Type_B_Channel,
                        Type_C_Period,
                        Method_cal,
                        List_Signature,
                        List_HERO,
                        List_Category,
                        List_Sub_Category,
                        List_Group_Class
             */
        }
        private void CmdGenerate_Click(object sender, EventArgs e)
        {
            //check unit/value/%
            set_typeA_Value();
            //check online/offline/o+o
            set_typeB_Channel();
            //check material type
            set_typeE_MaterialType();
            //check period
            set_TypeC_Period();
            //check method calculation
            Set_Method_Cal();
            Set_List_Signature();
            Set_List_HERO();
            Set_List_Category();
            Set_List_Sub_Category();
            Set_List_Group_Class();
            if (GLCompareList.Text.Length == 0)
            {
                MessageBox.Show("[Compare list] không được để trống.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (txtValue.Text.Length == 0 || double.Parse(txtValue.Text.Replace(",", "")) == 0)
            {
                MessageBox.Show("[Value] không được để trống hoặc = 0.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (Type_B_Channel.Length == 0)
            {
                MessageBox.Show("[Channel] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (Type_E_MaterialType.Length == 0)
            {
                MessageBox.Show("[Material] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (Type_C_Period.Length == 0)
            {
                MessageBox.Show("[Months] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (Method_cal.Length == 0)
            {
                MessageBox.Show("[Method Calculation] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (List_Signature.Length == 0)
            {
                MessageBox.Show("[Signature] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (List_HERO.Length == 0)
            {
                MessageBox.Show("[HERO] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (List_Category.Length == 0)
            {
                MessageBox.Show("[Category] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (List_Sub_Category.Length == 0)
            {
                MessageBox.Show("[Sub-Category] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else if (List_Group_Class.Length == 0)
            {
                MessageBox.Show("[Group-Class] không được để trống .../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else
            {
                try
                {
                    //xử lý abs
                    if (chkABS.Checked)
                    {
                        Type_ABS = "1";
                    }
                    else
                    {
                        Type_ABS = "0";
                    }
                    //xử ý số hàng ngàn 1,000
                    string _compare_value = "";
                    _compare_value = txtValue.Text.Replace(",", "");
                    //create data filter
                    New_sp nw = new New_sp();
                    nw.sp_Filter_GAP_DPvsBP
                    (
                        Connection_SQL._division,
                        Connection_SQL._fmkey,
                        Type_A,
                        Type_ABS,
                        GLCompareList.Text.Trim(),
                        _compare_value,
                        Type_B_Channel,
                        Type_E_MaterialType,
                        Type_C_Period,
                        Method_cal,
                        List_Signature,
                        List_HERO,
                        List_Category,
                        List_Sub_Category,
                        List_Group_Class
                    );
                    if (nw.b_success == "1")
                    {
                        //load summry
                        load_Grid_Summary();
                        //return gridview detail to null
                        gridControl2.DataSource = null;
                        gridControl2.ForceInitialize();

                        //Load condition script
                        //Get_Condition_List();
                        //get header
                        Load_Grid_Header();

                        GrpFilter.Dock = DockStyle.None;
                        GrpFilter.SendToBack();
                        GrpReport.Dock = DockStyle.Fill;
                        GrpReport.BringToFront();
                    }
                    else
                    {
                        MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }
        void Load_Grid_Header()
        {
            ArrayList array_p0 = new ArrayList()
                        {
                            "@Division",
                            "@FM_KEY",
                            "@Channel",
                            "@Header",
                            "@ListColumn",
                            "@Subgrp",
                            "@ShowAll_Channel"
                        };
            ArrayList array_v0 = new ArrayList()
                        {
                            Connection_SQL._division,
                            Connection_SQL._fmkey,
                            Type_B_Channel,
                            "H",
                            Type_C_Period,
                            "",
                            0
                        };
            dt_Filter_Header = null;
            dt_Filter_Header = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_get_Filter_GAP_DPvsBP", array_p0, array_v0);
            gridControl1.DataSource = dt_Filter_Header;
            gridControl1.ForceInitialize();
            format_gridview1();
            //gridView1.OptionsView.ColumnAutoWidth = false;
            //gridView1.Columns["ColSelected"].Width = 40;
            //gridView1.Columns["Channel"].Width = 50;
            //gridView1.Columns["DP"].Width = 70;
            //gridView1.Columns["BP"].Width = 70;
            //gridView1.Columns["GAP"].Width = 70;
            //gridView1.Columns["%GAP"].Width = 70;
            //gridView1.Columns["WOG"].Width = 70;
            gridView1.BestFitColumns();
            txtFCLine.Text = gridView1.RowCount.ToString("#,##0");
        }

        private void chkYTG_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("YTG");
        }
        void clear_Quaterly()
        {
            ra_Y0_Q1.Checked = false;
            ra_Y0_Q2.Checked = false;
            ra_Y0_Q3.Checked = false;
            ra_Y0_Q4.Checked = false;
            ra_ALL_Y0.Checked = false;

            ra_Y1_Q1.Checked = false;
            ra_Y1_Q2.Checked = false;
            ra_Y1_Q3.Checked = false;
            ra_Y1_Q4.Checked = false;
            ra_ALL_Y1.Checked = false;
        }
        void clear_period_control(string control_active)
        {
            if (control_active.ToUpper() == "SELECT_ALL")
            {
                LbError.Text = "";
                Year_Quaterly = Year_FC;

                if (chkSelectAllMonths.Checked)
                {
                    chkYTG.Checked = false;
                    clear_Quaterly();
                    _select_All = true;
                    get_Motnh_Datagridview(_select_All);
                }
                else
                {
                    _select_All = false;
                    get_Motnh_Datagridview(_select_All);
                }
            }
            else if (control_active.ToUpper() == "YTG")
            {
                LbError.Text = "";
                Year_Quaterly = Year_FC;
                //clear list month to false
                for (int i = 0; i < 12; i++)
                {
                    dataGridView1.Rows[0].Cells[i].Value = false;
                }
                if (chkYTG.Checked)
                {
                    clear_Quaterly();
                    chkSelectAllMonths.Checked = false;
                    for (int i = 0; i < Totalmonths; i++)
                    {
                        dataGridView1.Rows[0].Cells[Currentrow + i].Value = true;
                    }
                }
                else
                {
                    for (int i = 0; i < Totalmonths; i++)
                    {
                        dataGridView1.Rows[0].Cells[Currentrow + i].Value = false;
                    }
                }
                DataGridview_Readonly_Cell();
            }
            else if (control_active.ToUpper() == "QUATERLY")
            {
                Fill_months_Quaterly();
                DataGridview_Readonly_Cell();
            }
        }
        private void ra_Y0_Q1_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_Y0_Q2_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_Y0_Q3_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_Y0_Q4_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_Y1_Q1_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_Y1_Q2_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_Y1_Q3_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_Y1_Q4_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }
        private void chkSelectAllMonths_CheckStateChanged(object sender, EventArgs e)
        {
            clear_period_control("SELECT_ALL");
        }
        private void ra_ALL_Y0_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }

        private void ra_ALL_Y1_CheckedChanged(object sender, EventArgs e)
        {
            clear_period_control("QUATERLY");
        }
        private void txtValue_EditValueChanged(object sender, EventArgs e)
        {
            format_value(txtValue);
        }
        void format_value(TextEdit txt)
        {
            try
            {
                //if (txt.Text.Trim().Length != 0)
                //{
                //    //txt.Text = double.Parse(txt.Text.Trim()).ToString("#,##0");
                //    //txt.Text= string.Format("{0:#,##0.00}", double.Parse(txt.Text));
                //}
                //else
                //{
                //    txt.Text = "0";
                //}
                if (txt.Text == "" || txt.Text == "0") return;
                decimal number;
                number = decimal.Parse(txt.Text, System.Globalization.NumberStyles.Currency);
                txt.Text = number.ToString("#,#");
                txt.SelectionStart = txt.Text.Length;
            }
            catch
            {
                txt.Text = "0";
            }
        }

        private void ra_Individual_CheckedChanged(object sender, EventArgs e)
        {
            if (ra_Individual.Checked)
            {
                Method_cal = "INDIVIDUAL";
            }
        }

        private void ra_Summry_CheckedChanged(object sender, EventArgs e)
        {
            if (ra_Summry.Checked)
            {
                Method_cal = "SUMMARY";
            }
        }

        private void gridView1_Click(object sender, EventArgs e)
        {
            _currentrow_header = gridView1.FocusedRowHandle;
            _list_ForecastingLine = "";
            if (_currentrow_header >= 0)
            {
                _forecastingLine = gridView1.GetRowCellValue(_currentrow_header, "Forecasting Line").ToString().Replace("?", "");
                _Channel = gridView1.GetRowCellValue(_currentrow_header, "Channel").ToString();
            }
            else
            {
                _forecastingLine = "";
                _Channel = "";
            }
            Load_grid_Detail(_list_ForecastingLine);
        }
        void format_gridview2()//string format_type)
        {
            for (int i = 0; i < gridView2.Columns.Count; i++)
            {
                //MessageBox.Show(gridView2.Columns[i].Name);
                if (cls_function.Left(gridView2.Columns[i].ToString(), 1) == "Y" || cls_function.Left(gridView2.Columns[i].ToString(), 2) == "(V")
                {
                    gridView2.Columns[i].DisplayFormat.FormatType = FormatType.Numeric;
                    gridView2.Columns[i].DisplayFormat.FormatString = "N0";
                }
            }
        }
        void format_gridview1()
        {
            for (int i = 0; i < gridView1.Columns.Count; i++)
            {
                //MessageBox.Show(gridView2.Columns[i].Name);
                if (gridView1.Columns[i].ToString() == "DP" || gridView1.Columns[i].ToString() == "BP"
                    || gridView1.Columns[i].ToString() == "GAP" || gridView1.Columns[i].ToString() == "%GAP"
                    || gridView1.Columns[i].ToString() == "WOG")
                {
                    gridView1.Columns[i].DisplayFormat.FormatType = FormatType.Numeric;
                    gridView1.Columns[i].DisplayFormat.FormatString = "N0";
                }
            }
        }
        private void gridView2_CustomUnboundColumnData(object sender, DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs e)
        {

        }

        private void gridView2_RowCellStyle(object sender, RowCellStyleEventArgs e)
        {

        }

        private void gridView2_Click(object sender, EventArgs e)
        {
            _currentrow_detail = gridView2.FocusedRowHandle;

        }

        private void gridView2_RowStyle(object sender, RowStyleEventArgs e)
        {

        }

        private void gridView2_CustomDrawRowIndicator(object sender, RowIndicatorCustomDrawEventArgs e)
        {
            cls_function.Sequence_Gridcontrol(gridView2, e);
        }

        private void gridView1_CustomDrawRowIndicator(object sender, RowIndicatorCustomDrawEventArgs e)
        {
            cls_function.Sequence_Gridcontrol(gridView1, e);
        }
        RepositoryItem textEdit;
        private void AddGridRepositoryItem()
        {
            textEdit = new RepositoryItemTextEdit();
            textEdit.AllowHtmlDraw = DevExpress.Utils.DefaultBoolean.True;
            textEdit.ReadOnly = true;
            gridControl1.RepositoryItems.Add(textEdit);

            textEdit.DisplayFormat.FormatType = DevExpress.Utils.FormatType.Numeric;
            textEdit.DisplayFormat.FormatString = "p";
            gridView2.Columns[0].ColumnEdit = textEdit;

        }
        private void gridView2_CustomDrawCell(object sender, DevExpress.XtraGrid.Views.Base.RowCellCustomDrawEventArgs e)
        {
            try
            {
                if (gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "6. Total Qty")
                {
                    e.Appearance.BackColor = Color.LightGray;
                    e.Appearance.Font = new Font(e.Appearance.Font.FontFamily, e.Appearance.Font.Size, FontStyle.Bold);
                }
                if (!ra_Value.Checked)
                {
                    foreach (var item in Type_C_Period.Split(","))
                    {
                        if (e.RowHandle >= 0)
                        {
                            if (e.Column.FieldName == item)
                            {
                                //gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "8. BP vs FC (u)"
                                if (gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "9. BP vs FC (%)" && ra_percent.Checked == true)
                                {
                                    if (GLCompareList.Text.Trim() == ">")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0")) > double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                                e.Column.DisplayFormat.FormatType = DevExpress.Utils.FormatType.Numeric;
                                                e.Column.DisplayFormat.FormatString = "p";
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0") > double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                                e.Column.DisplayFormat.FormatType = DevExpress.Utils.FormatType.Numeric;
                                                e.Column.DisplayFormat.FormatString = "p";
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == ">=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0")) >= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                                e.Column.DisplayFormat.FormatType = DevExpress.Utils.FormatType.Numeric;
                                                e.Column.DisplayFormat.FormatString = "p";
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0") >= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                                e.Column.DisplayFormat.FormatType = DevExpress.Utils.FormatType.Numeric;
                                                e.Column.DisplayFormat.FormatString = "p";
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0")) < double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0") < double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0")) <= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0") <= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0")) == double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString().Replace("%", "") : "0") == double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }

                                    }
                                    else if (GLCompareList.Text.Trim() == "<>")
                                    {
                                        if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") != double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                        {
                                            e.Appearance.BackColor = Color.LightPink;
                                        }
                                    }
                                }
                                else if (gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "8. BP vs FC (u)" && ra_Unit.Checked == true)
                                {
                                    if (GLCompareList.Text.Trim() == ">")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) > double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") > double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == ">=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) >= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") >= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) < double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") < double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<=")
                                    {
                                        //e.Appearance.Font = new Font(e.Appearance.Font.FontFamily, e.Appearance.Font.Size, FontStyle.Bold);
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) <= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") <= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) == double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") == double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<>")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) != double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") != double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    foreach (var item in Type_C_Period.Split(","))
                    {
                        if (e.RowHandle >= 0)
                        {
                            if (e.Column.FieldName == "(Value)_" + item)
                            {
                                // gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "8. BP vs FC (u)"
                                if (gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "8. BP vs FC (u)" && ra_Value.Checked == true)
                                {
                                    if (GLCompareList.Text.Trim() == ">")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) > double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") > double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == ">=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) >= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") >= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) < double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") < double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) <= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") <= double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "=")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) == double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") == double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                    else if (GLCompareList.Text.Trim() == "<>")
                                    {
                                        if (chkABS.Checked)
                                        {
                                            if (Math.Abs(double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0")) != double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                        else
                                        {
                                            if (double.Parse((e.CellValue != null) ? e.CellValue.ToString() : "0") != double.Parse(txtValue.Text.Trim().Replace(",", "")))
                                            {
                                                e.Appearance.BackColor = Color.LightPink;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch
            {

            }
        }

        private void cmdBackCondition_Click(object sender, EventArgs e)
        {
            GrpReport.Dock = DockStyle.None;
            GrpReport.SendToBack();
            GrpFilter.Dock = DockStyle.Fill;
            GrpFilter.BringToFront();
            //MessageBox.Show(Math.Abs(-1).ToString());
        }

        private void GLCompareList_EditValueChanged(object sender, EventArgs e)
        {
            //MessageBox.Show(GLCompareList.Text);
        }

        private void GLCompareList_CustomDisplayText(object sender, DevExpress.XtraEditors.Controls.CustomDisplayTextEventArgs e)
        {
            //if (GLCompareList.EditValue == null)
            //{
            //    e.DisplayText = "=";
            //}
        }

        private void chkShowAll_Channel_CheckedChanged(object sender, EventArgs e)
        {
            Load_grid_Detail(_list_ForecastingLine);
        }

        private void gridView2_CellValueChanged(object sender, DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs e)
        {
            try
            {
                if
                (
                        gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "1. Baseline Qty"
                    || gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "2. Promo Qty(Single)"
                    || gridView2.GetRowCellValue(e.RowHandle, "Time series").ToString() == "4. Launch Qty"
                )
                {
                    string _id = gridView2.GetRowCellValue(e.RowHandle, "ID").ToString();
                    string _fieldName = e.Column.FieldName;
                    string _value = gridView2.GetRowCellValue(e.RowHandle, _fieldName).ToString();

                    New_sp nw = new New_sp();
                    nw.sp_Filter_GAP_Adjust_OK
                    (
                        Connection_SQL._division,
                        Connection_SQL._fmkey,
                        _id,
                        _fieldName,
                        _value
                    );
                    if (nw.b_success == "1")
                    {
                        Load_grid_Detail(_list_ForecastingLine);
                    }
                    else
                    {
                        MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void gridView1_CellValueChanged(object sender, DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs e)
        {

        }
        public static string _list_ForecastingLine = "";
        private void cmdApply_Click(object sender, EventArgs e)
        {
            try
            {
                _list_ForecastingLine = "";
                for (int i = 0; i < gridView1.RowCount; i++)
                {
                    if (gridView1.GetRowCellValue(i, "Selected").ToString() == "True")
                    {
                        if (_list_ForecastingLine.Length == 0)
                        {
                            _list_ForecastingLine = gridView1.GetRowCellValue(i, "Forecasting Line").ToString().Replace("?", "")
                                                    + "**"
                                                    + gridView1.GetRowCellValue(i, "Channel").ToString();

                        }
                        else
                        {
                            _list_ForecastingLine = _list_ForecastingLine + "," + gridView1.GetRowCellValue(i, "Forecasting Line").ToString()
                                                                                + "**"
                                                                                + gridView1.GetRowCellValue(i, "Channel").ToString();
                        }
                    }
                }
                Load_grid_Detail(_list_ForecastingLine);
            }
            catch
            {

            }
        }

        private void chk_SelectedAll_FCLine_CheckedChanged(object sender, EventArgs e)
        {
            for (int i = 0; i < gridView1.RowCount; i++)
            {
                if (chk_SelectedAll_FCLine.Checked)
                {
                    gridView1.SetRowCellValue(i, "Selected", true);
                }
                else
                {
                    gridView1.SetRowCellValue(i, "Selected", false);
                }
            }
        }

        private void txtValue_EditValueChanging(object sender, DevExpress.XtraEditors.Controls.ChangingEventArgs e)
        {
            //format_value(txtValue);
        }

        private void gridView2_CustomDrawGroupRow(object sender, DevExpress.XtraGrid.Views.Base.RowObjectCustomDrawEventArgs e)
        {
            //GridGroupRowInfo info = e.Info as GridGroupRowInfo;
            //info.GroupText = info.GroupValueText;
            //e.DefaultDraw();
            //e.Handled = true;
            e.Appearance.Font = new Font("Arial", (float)12);
            e.Appearance.ForeColor= Color.DarkBlue;
        }
        //void format_percent_gridview2(GridColumn _gridcolumn)
        //{
        //    GridFormatRule gridFormatRule = new GridFormatRule();
        //    FormatConditionRuleExpression formatConditionRuleExpression = new FormatConditionRuleExpression();
        //    gridFormatRule.Column = _gridcolumn;
        //    gridFormatRule.ApplyToRow = true;
        //    //formatConditionRuleExpression.PredefinedName = "Red Fill, Red Text";
        //    formatConditionRuleExpression.Expression = "='9. BP vs FC (%)'";
        //    gridFormatRule.Rule = formatConditionRuleExpression;
        //    gridView1.FormatRules.Add(gridFormatRule);
        //}
    }
}
