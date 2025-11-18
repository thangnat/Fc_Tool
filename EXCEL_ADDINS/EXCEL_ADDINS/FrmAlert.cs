using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public partial class FrmAlert : Form
    {
        public string _division = string.Empty;
        public static string _sp_name = "sp_get_Fc_Table_Status";
        private int desiredStartLocationX;
        private int desiredStartLocationY;
        public static string _alias_error_name = string.Empty;
        public static string _table_error_name = string.Empty;
        public static string _table_error_final_name = string.Empty;
        public static string _tag_name_system = string.Empty;
        //---------------------------------------------------------------
        public static bool _Missing_master_data = false;
        public static bool _Duplicate_master_data = false;
        public static bool _Missing_bom = false;
        public static bool _Missing_RSP = false;
        public static bool _Inconsistency = false;
        public static int _gridview3_row_index = -1;
        public static string _type_name = string.Empty;
        public static DataTable dt_error_table_for = null;
        public static DataTable dt_error_soh = null;

        public static DataTable dt_list_tag_name = null;
        public FrmAlert()
        {
            InitializeComponent();
            //_division = Connection_SQL._division.Trim();
            Get_data_gen_technical_status();
            Load_error_alert_color();
        }
        void Get_data_gen_technical_status()
        {
            dt_list_tag_name = new DataTable();
            //_sp_name = "sp_Get_SellIn";
            ArrayList array_param = new ArrayList() { "@Division" };
            ArrayList array_value = new ArrayList() { Connection_SQL._division.Trim() };
            dataGridView1.GetType().GetProperty("DoubleBuffered", BindingFlags.Instance | BindingFlags.NonPublic).SetValue(dataGridView1, true, null);
            dt_list_tag_name = Connection_SQL.GetDataTable(@"select * from fnc_get_genarated_status('" + Connection_SQL._division + "')"); ;// Connection_SQL.Exec_StoreProc_datatable_Admin(_sp_name, array_param, array_value);

            //dataGridView1.Dispose();
            dataGridView1.DataSource = null;
            dataGridView1.DataSource = dt_list_tag_name;
            dataGridView1.Columns[0].Visible = false;
            dataGridView1.Columns[1].Visible = false;
            dataGridView1.Columns[2].Visible = false;
            dataGridView1.Columns[5].Visible = false;
            dataGridView1.Columns[6].Visible = false;
            dataGridView1.Columns[7].Visible = false;
            dataGridView1.Columns[3].Width = 200;
            dataGridView1.Columns[4].Width = 120;
            dataGridView1.AllowUserToAddRows = false;
        }

        void Get_data_error_SOH()
        {
            dt_error_soh = new DataTable();
            //_sp_name = "sp_Get_SellIn";
            //ArrayList array_param = new ArrayList() { "@Division" };
            //ArrayList array_value = new ArrayList() { Connection_SQL._division.Trim() };
            dataGridView2.GetType().GetProperty("DoubleBuffered", BindingFlags.Instance | BindingFlags.NonPublic).SetValue(dataGridView2, true, null);
            ArrayList array_p1 = new ArrayList()
            {
                "@Division",
                "@FM_KEY",
                "@Type"
            };
            ArrayList array_v1 = new ArrayList()
            {
                Connection_SQL._division,
                Connection_SQL._fmkey,
                "full"
            };
            dt_error_soh = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_Create_Raw_vs_Convert_SOH_MTD_SI_FINAL", array_p1, array_v1);

            //dataGridView1.Dispose();
            dataGridView2.DataSource = null;
            dataGridView2.DataSource = dt_error_soh;
        }
        private void FrmAlert_Load(object sender, EventArgs e)
        {
            this.SetDesktopLocation(desiredStartLocationX, desiredStartLocationY);
        }
        void Get_eror_table_for(string typename_)
        {
            //dataGridView3.GetType().GetProperty("DoubleBuffered", BindingFlags.Instance | BindingFlags.NonPublic).SetValue(dataGridView3, true, null);
            //DataTable dt_error_table_for = new DataTable();
            //get detail
            ArrayList array_p1 = new ArrayList()
            {
                "@Division",
                "@FM_KEY",
                "@TypeName"
            };
            ArrayList array_v1 = new ArrayList()
            {
                Connection_SQL._division,
                Connection_SQL._fmkey,
                typename_
            };
            dt_error_table_for = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_validate_mismatch_Status", array_p1, array_v1);


            for (int i = 0; i < dt_error_table_for.Rows.Count; i++)
            {
                string _tablename = "";
                _tablename = dt_error_table_for.Rows[0]["Table Name"].ToString();

                DataTable dt_ = new DataTable();
                dt_=get_data_error_datagridview(_tablename, typename_);

                dataGridViewSI_HIS_FC.DataSource = null;
                dataGridViewSI_HIS_FC.DataSource = dt_;
                dataGridViewSI_HIS_FC.AllowUserToAddRows = false;
            }            
        }
       
        public DataTable get_data_error_datagridview(string _tablename, string typename_)
        {
            DataTable dt_error = new DataTable();
            string _sql = @"select * 
                            from " + _tablename + @"
                            where 
                                [Division]='"+Connection_SQL._division+@"'
                            and [FM_KEY]='"+Connection_SQL._fmkey+@"'
                            and [Type Name] IN(select value from string_split('" + typename_ + "',','))";

            dt_error = Connection_SQL.GetDataTable(_sql);
            return dt_error;
        }
        void cmd_visible(bool visible)
        {
            cmdMasterData.Visible = visible;
            cmdMissingBom.Visible = visible;
            cmdDuplicate_Master_Data.Visible = visible;
            cmdInconsistency.Visible = visible;
            cmdRSP.Visible = visible;
        }
        void Load_error_alert_color()
        {
            cmd_visible(false);

            DataTable dt_error_alert_color = new DataTable();
            string _sql = @"select * from fnc_fc_error_alert('" + Connection_SQL._division + "','" + Connection_SQL._fmkey + "')";

            dt_error_alert_color = Connection_SQL.GetDataTable(_sql);
            if (dt_error_alert_color.Rows.Count > 0)
            {
                if(int.Parse(dt_error_alert_color.Rows[0]["Missing Master Data"].ToString()) > 0)
                {
                    _Missing_master_data = true;
                    cmdMasterData.Visible = _Missing_master_data;
                }
                if (int.Parse(dt_error_alert_color.Rows[0]["Duplicate master data"].ToString()) > 0)
                {
                    _Duplicate_master_data = true;
                    cmdDuplicate_Master_Data.Visible = _Duplicate_master_data;
                }
                if (int.Parse(dt_error_alert_color.Rows[0]["Missing BOM"].ToString()) > 0)
                {
                    _Missing_bom = true;
                    cmdMissingBom.Visible = _Missing_bom;
                }
                if (int.Parse(dt_error_alert_color.Rows[0]["Missing RSP"].ToString()) > 0)
                {
                    _Missing_RSP = true;
                    cmdRSP.Visible = _Missing_RSP;
                }
                if (int.Parse(dt_error_alert_color.Rows[0]["Inconsistency"].ToString()) > 0)
                {
                    _Inconsistency = true;
                    cmdInconsistency.Visible = _Inconsistency;
                }
            }
        }
        public FrmAlert(int x, int y) : this()
        {
            this.desiredStartLocationX = x;
            this.desiredStartLocationY = y;

            Load += new EventHandler(FrmAlert_Load);
        }
        

        

        private void dataGridView1_Click(object sender, EventArgs e)
        {
            
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {           
            //cmd_visible(false);
            _tag_name_system = dataGridView1.Rows[e.RowIndex].Cells[1].Value.ToString();
            _alias_error_name = dataGridView1.Rows[e.RowIndex].Cells[7].Value.ToString();
            _table_error_name = _alias_error_name + "validate_mismatch_";
            //MessageBox.Show(_tag_name_system);
            //if (_tag_name_system == "tag_add_FC_SI_Group_FC_SI_Promo_Bom")
            //{
            //    cmdMissingBom.Visible = true;
            //    cmdRSP.Visible = true;
            //    this.Width = 1557;
                
            //}
            //else if (_tag_name_system == "tag_gen_FM_FC_SI_BASELINE")
            //{
            //    cmdMasterData.Visible = true;
            //    cmdMissingBom.Visible = true;
            //    cmdRSP.Visible = true;
            //    this.Width = 1557;
            //}
            //else if
            //(
            //        _tag_name_system == "tag_add_FC_SI_Group_FC_SI_FOC"
            //    || _tag_name_system == "tag_add_FC_SI_Group_FC_SI_Launch_Single"
            //    || _tag_name_system == "tag_add_FC_SI_Group_FC_SI_Promo_Single"
            //)
            //{
            //    cmdMasterData.Visible = true;
            //    cmdRSP.Visible = true;
            //    this.Width = 1557;
            //}
            //else
            //{
            //    this.Width = 645;
            //}
            dataGridViewSI_HIS_FC.DataSource = null;
        }
        private void cmdMasterData_Click(object sender, EventArgs e)
        {
            _type_name = "MasterData";
            //if (_tag_name_system == "tag_gen_FM_FC_SI_BASELINE" && _button_name == "MasterData")
            //{
            //    _table_error_final_name = "fnc_" + _table_error_name + _button_name + "('" + Connection_SQL._division + "','" + Connection_SQL._fmkey + "')";
            //}
            //else
            //{
            //    _table_error_final_name = _table_error_name + _button_name;
            //}
            Get_eror_table_for(_type_name);
            //get_data_error(_table_error_final_name);
            Get_data_error_SOH();
        }

        private void cmdRSP_Click(object sender, EventArgs e)
        {
            //_table_error_final_name = _table_error_name + "RSP";
            _type_name = "RSP";
            Get_eror_table_for(_type_name);
            //get_data_error(_table_error_final_name);
        }

        private void cmdMissingBom_Click(object sender, EventArgs e)
        {
            //_table_error_final_name = "fnc_" + _table_error_name + "BOM_vs_masterdata('"+Connection_SQL._division+"','"+Connection_SQL._fmkey+"')";
            _type_name = "BOM_vs_masterbom,BOM_vs_masterdata";
            Get_eror_table_for(_type_name);
            //get_data_error(_table_error_final_name);

        }

        private void cmdDuplicate_Master_Data_Click(object sender, EventArgs e)
        {
            _type_name = "DEVELOP";
            Get_eror_table_for(_type_name);
        }

        private void cmdInconsistency_Click(object sender, EventArgs e)
        {
            _type_name = "DEVELOP";
            Get_eror_table_for("DEVELOP");
        }

        private void dataGridView3_RowEnter(object sender, DataGridViewCellEventArgs e)
        {
            //_gridview3_row_index = e.RowIndex;
            //dataGridView3.Rows[_gridview3_row_index].ReadOnly = true;
        }

        private void dataGridView3_Click(object sender, EventArgs e)
        {
            //string _tablename = dataGridView3.Rows[_gridview3_row_index].Cells[1].Value.ToString();
            //MessageBox.Show(_tablename);
            //get_data_error(_tablename,_type_name);
        }
    }
}
