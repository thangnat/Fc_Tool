using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Linq;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public partial class FrmRe_GenPartial_WF : Form
    {
        public static string _division = string.Empty;
        public static string _fmkey = string.Empty;
        //public static DataTable dt = new DataTable();
        public static DataTable dt_list_function = new DataTable();
        public static bool _action_case = false;
        public static DataTable dt_signature = new DataTable();
        public static int _total_signature = 0;
        private bool allowClose = false;

        public FrmRe_GenPartial_WF()//string division, string fmkey)
        {
            InitializeComponent();
            dataGridView1.GetType().GetProperty("DoubleBuffered", BindingFlags.Instance | BindingFlags.NonPublic).SetValue(dataGridView1, true, null);
            _division = Connection_SQL._division;
            _fmkey = Connection_SQL._fmkey;
            load_List_function_active("");

        }
        public FrmRe_GenPartial_WF(int x, int y) : this()
        {
            // Ignore the passed coordinates and use CenterScreen instead
            this.StartPosition = FormStartPosition.CenterScreen;

            Load += new EventHandler(FrmRe_GenPartial_WF_Load);
        }
        private void FrmRe_GenPartial_WF_Load(object sender, EventArgs e)
        {
            LbProcessing.Visible = false;
            if (Connection_SQL._userID != "admin1" && Connection_SQL._userID != "adminfc")
            {
                menuStrip1.Visible = false;
            }
            else
            {
                menuStrip1.Visible = true;
            }
            // Form will center automatically based on StartPosition property
            //progressBar1.Style = ProgressBarStyle.Marquee;
            //progressBar1.Visible = false;

            //string _sql = @"select distinct 
            //                    [Signature] 
            //                from FC_FM_Original_" + Connection_SQL._division + "_" + Connection_SQL._fmkey;

            string _sql = @"select * from fnc_FC_Signature('" + Connection_SQL._division + "')";

            dt_signature = Connection_SQL.GetDataTable(_sql);
            if (dt_signature.Rows.Count > 0)
            {
                _total_signature = dt_signature.Rows.Count + 1;
            }
            //foreach (DataGridViewRow row in dataGridView1.Rows)
            //if (Convert.ToInt32(row.Cells[7].Value) < Convert.ToInt32(row.Cells[10].Value))
            //{
            //    row.DefaultCellStyle.BackColor = Color.GreenYellow;
            //}
        }
        void load_List_function_active(string selected_)
        {
            //get detail
            ArrayList array_p1 = new ArrayList()
            {
                "@Division",
                "@FM_KEY",
                "@Selected"
            };
            ArrayList array_v1 = new ArrayList()
            {
                Connection_SQL._division,
                Connection_SQL._fmkey,
                selected_
            };
            dt_list_function = null;
            dt_list_function = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_Get_Function_Active_By_PC_New", array_p1, array_v1);
            dataGridView1.DataSource = dt_list_function;
            //MessageBox.Show(dt_list_function.Rows.Count.ToString());
            dataGridView1.AllowUserToAddRows = false;
            dataGridView1.Columns[0].Width = 50;
            dataGridView1.Columns[1].Visible = true;
            dataGridView1.Columns[2].Visible = false;
            dataGridView1.Columns[3].Width = 170;
            dataGridView1.Columns[4].Visible = false;
            dataGridView1.Columns[5].Visible = false;

            // Adjust DataGridView width to match total column width
            int totalWidth = 0;
            foreach (DataGridViewColumn col in dataGridView1.Columns)
            {
                if (col.Visible)
                {
                    totalWidth += col.Width;
                }
            }
            // Add extra space for row headers and borders
            int dataGridWidth = totalWidth + dataGridView1.RowHeadersWidth + 3;

            // Adjust SplitContainer splitter distance to match DataGridView width
            if (splitContainer1 != null && dataGridWidth > 0)
            {
                splitContainer1.SplitterDistance = dataGridWidth;
            }
        }

        void Run_Function_Partial(string sp_name_)
        {
            string sp_name = sp_name_;
            try
            {
                if (sp_name == "tag_add_BFL_Master")
                {
                    New_sp nw = new New_sp();
                    nw.sp_Add_FC_BFL_Master
                    (
                        _division,
                        _fmkey,
                        "",//month
                        "",//type
                        "0"//only trend
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_Add_ZV14_Forecast")
                {
                    New_sp nw = new New_sp();
                    nw.sp_Add_ZV14_Forecast
                    (
                        _division
                    );
                }
                else if (sp_name == "tag_update_wf_pass_02_years_new")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_update_wf_pass_02_years_new
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_FM_FC_SI")
                {
                    New_sp nw = new New_sp();
                    nw.sp_Sum_FC_FM_baseLine_new
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_fm_non_modeling")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_gen_fm_non_modeling_new
                    (
                        _division,
                        _fmkey,
                        "full",
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_SUBGROUP_VLOOKUP")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_gen_SUBGROUP_VLOOKUP
                    (
                        _division,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_Gen_Bomheader_FDR")
                {
                    New_sp nw = new New_sp();
                    nw.sp_Gen_BomHeader_Forecast_FDR
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_Gen_Bomheader_FOC_TO_VP")
                {
                    New_sp nw = new New_sp();
                    nw.sp_Gen_BomHeader_Forecast_FOC_TO_VP
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                        //MessageBox.Show(nw.c_errmsg, "L'Oreal", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else if (sp_name == "tag_Gen_Bomheader_SO_OPTIMUS")
                {
                    New_sp nw = new New_sp();
                    nw.sp_Gen_BomHeader_Forecast_SO_OPTIMUS
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_budget_budget")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_gen_budget_budget_New
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_budget_pre_budget")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_gen_budget_pre_budget_new
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_budget_trend")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_gen_budget_trend_new
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_wf_value_table")//no use
                {
                    New_sp nw = new New_sp();
                    nw.sp_Gen_WF_Value_New
                    (
                        _division,
                        _fmkey,
                        "VALUE"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_add_FC_SI_Group_FC_SO_OPTIMUS_Promo_Bom")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_Promo_Bom
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_add_FC_SI_Group_FC_SO_OPTIMUS_NORMAL")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_NORMAL
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_add_FC_SI_Group_FC_SI_FOC")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_add_FC_SI_Group_FC_SI_FOC
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_add_FC_SI_Group_FC_SI_Launch_Single")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_add_FC_SI_Group_FC_SI_Launch_Single
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_add_FC_SI_Group_FC_SI_Promo_Bom")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_add_FC_SI_Group_FC_SI_Promo_Single")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New
                    (
                        _division,
                        _fmkey,
                        "1"
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_git")
                {
                    //MessageBox.Show(sp_name);
                    New_sp nw = new New_sp();
                    nw.sp_FC_GIT_NEW
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_update_wf_sit")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_update_wf_sit
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        //sp_calculate_total
                        New_sp nw1 = new New_sp();
                        nw1.sp_calculate_total
                        (
                            _division,
                            _fmkey,
                            "All"
                        );
                        if (nw1.b_success == "1")
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                        }
                        else
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                        }
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_update_wf_sit_day")
                {
                    //MessageBox.Show(sp_name);
                    New_sp nw = new New_sp();
                    nw.sp_tag_update_wf_sit_day
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        //sp_calculate_total
                        New_sp nw1 = new New_sp();
                        nw1.sp_calculate_total
                        (
                            _division,
                            _fmkey,
                            "All"
                        );
                        if (nw1.b_success == "1")
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                        }
                        else
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                        }
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_gen_soh")
                {
                    //MessageBox.Show(sp_name);
                    New_sp nw = new New_sp();
                    nw.sp_tag_gen_soh
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_update_wf_mtd_si")
                {
                    //MessageBox.Show(sp_name);
                    New_sp nw = new New_sp();
                    nw.sp_tag_update_wf_mtd_si
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_update_wf_ver_m_1")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_update_wf_ver_m_1
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                else if (sp_name == "tag_Update_WF_AVG_HIS_unit")
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_Update_WF_AVG_HIS_unit
                    (
                        _division,
                        _fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                    }
                }
                //else if (sp_name == "tag_Update_WF_AVG_HIS_3M_Y0_SI_unit")
                //{
                //    New_sp nw = new New_sp();
                //    nw.sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_Unit
                //    (
                //        _division,
                //        _fmkey
                //    );
                //    if (nw.b_success == "1")
                //    {
                //        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                //    }
                //    else
                //    {
                //        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                //    }
                //}
                //else if (sp_name == "tag_update_wf_total_slob")
                //{
                //    New_sp nw = new New_sp();
                //    nw.sp_tag_update_wf_total_slob
                //    (
                //        _division,
                //        _fmkey,
                //        "Re-Gen"
                //    );
                //    if (nw.b_success == "1")
                //    {
                //        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                //    }
                //    else
                //    {
                //        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                //    }
                //}
                //else if (sp_name == "tag_update_wf_O_O_slob")
                //{
                //    New_sp nw = new New_sp();
                //    nw.sp_tag_update_wf_O_O_slob
                //    (
                //        _division,
                //        _fmkey,
                //        "Re-Gen"
                //    );
                //    if (nw.b_success == "1")
                //    {
                //        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                //    }
                //    else
                //    {
                //        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                //    }
                //}
                else if (sp_name == "tag_update_wf_pass_02_years")
                {
                    New_sp nw1 = new New_sp();
                    nw1.sp_Create_V_His_SI_Final
                    (
                        _division,
                        _fmkey,
                        "h"
                    );
                    if (nw1.b_success == "1")
                    {
                        New_sp nw = new New_sp();
                        nw.sp_tag_update_wf_pass_02_years_new
                        (
                            _division,
                            _fmkey,
                            "1"
                        );
                        MessageBox.Show(nw.b_success);
                        if (nw.b_success == "1")
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                        }
                        else
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                        }
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw1.c_errmsg;
                    }
                }
                else if (sp_name == "tag_update_BP_unit")
                {
                    if (_division == "CPD")
                    {
                        New_sp nw = new New_sp();
                        nw.sp_tag_update_BP_unit
                        (
                            _division,
                            _fmkey,
                            "1"
                        );
                        MessageBox.Show(nw.b_success);
                        if (nw.b_success == "1")
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + "successed.../";
                        }
                        else
                        {
                            txtprocessStatus.Text = txtprocessStatus.Text + "\n " + nw.c_errmsg;
                        }
                    }
                    else
                    {
                        MessageBox.Show("Division: " + _division + " Not permision.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    }
                }
            }
            catch (Exception ex)
            {
                txtprocessStatus.Text = txtprocessStatus.Text + "\n " + ex.Message;
            }
        }
        private void dataGridView1_Click(object sender, EventArgs e)
        {
            //for (int i = 6; i < (_total_signature + 6); i++)
            //{
            //    if (dataGridView1.CurrentCell.ColumnIndex == 0)
            //    {
            //        //MessageBox.Show(dataGridView1.Rows[e.RowIndex].Cells[0].Value.ToString());
            //        if (bool.Parse(dataGridView1.Rows[dataGridView1.CurrentCell.RowIndex].Cells[0].Value.ToString()) == true)
            //        {
            //            //MessageBox.Show(e.ColumnIndex.ToString());
            //            dataGridView1[i, dataGridView1.CurrentCell.RowIndex].Value = true;
            //        }
            //        else
            //        {
            //            dataGridView1[i, dataGridView1.CurrentCell.RowIndex].Value = false;
            //        }
            //    }
            //}
        }

        private void dataGridView1_DoubleClick(object sender, EventArgs e)
        {
            //string sp_name_ = dataGridView1.CurrentCell.Value.ToString();
            //DialogResult drl = MessageBox.Show("Do you want to run this function [" + sp_name_ + "]", "[L'Oreal]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            //if (drl == DialogResult.Yes)
            //{
            //    Run_Function_Partial(sp_name_);
            //}
        }
        void Apply_selected_to_system(string typeview_)
        {
            try
            {
                string _list_id_function = "";
                string _list_id_signature_All = "";
                string _list_selected = "";

                for (int i = 0; i < dataGridView1.RowCount; i++)
                {
                    string _id_function = "";
                    _id_function = dataGridView1.Rows[i].Cells[1].Value.ToString();

                    if (_list_id_function.Length == 0)
                    {
                        _list_id_function = _id_function;
                    }
                    else
                    {
                        _list_id_function = _list_id_function + "," + _id_function;
                    }
                }
                if (chkAllowshowerrorInfo.Checked)
                {
                    FrmInputMessage frm = new FrmInputMessage("xxx" + Connection_SQL._division + "_" + Connection_SQL._fmkey, _list_id_function);
                    frm.StartPosition = FormStartPosition.CenterScreen;
                    frm.ShowDialog();
                }

                for (int i = 0; i < dataGridView1.RowCount; i++)
                {

                    string _list_id_signature = "";
                    if (bool.Parse(dataGridView1.Rows[i].Cells[0].Value.ToString()))
                    {
                        for (int ii = 6; ii < (_total_signature + 6 - 1); ii++)
                        {
                            if (bool.Parse(dataGridView1.Rows[i].Cells[ii].Value.ToString()))
                            {
                                if (_list_id_signature.Length == 0)
                                {
                                    _list_id_signature = dataGridView1.Columns[ii].HeaderText.Replace("'", "''");
                                }
                                else
                                {
                                    _list_id_signature = _list_id_signature + "*" + dataGridView1.Columns[ii].HeaderText.Replace("'", "''");
                                }
                            }

                        }
                    }
                    else
                    {
                        _list_id_signature = "NULL";
                    }
                    //input list
                    if (_list_id_signature_All.Length == 0)
                    {
                        _list_id_signature_All = _list_id_signature;
                    }
                    else
                    {
                        _list_id_signature_All = _list_id_signature_All + "," + _list_id_signature;
                    }
                }
                if (chkAllowshowerrorInfo.Checked)
                {
                    FrmInputMessage frm1 = new FrmInputMessage("xxx" + Connection_SQL._division + "_" + Connection_SQL._fmkey, _list_id_signature_All);
                    frm1.StartPosition = FormStartPosition.CenterScreen;
                    frm1.ShowDialog();
                }

                //MessageBox.Show("_list_id_signature_All: " + _list_id_signature_All);
                for (int i = 0; i < dataGridView1.RowCount; i++)
                {
                    string _selected = "0";
                    if (bool.Parse(dataGridView1.Rows[i].Cells[0].Value.ToString()))
                    {
                        _selected = "1";
                    }
                    else
                    {
                        _selected = "0";
                    }
                    if (_list_selected.Length == 0)
                    {
                        _list_selected = _selected;
                    }
                    else
                    {
                        _list_selected = _list_selected + "," + _selected;
                    }
                }
                if (chkAllowshowerrorInfo.Checked)
                {
                    FrmInputMessage frm2 = new FrmInputMessage("xxx" + Connection_SQL._division + "_" + Connection_SQL._fmkey, _list_selected);
                    frm2.StartPosition = FormStartPosition.CenterScreen;
                    frm2.ShowDialog();
                }

                New_sp nw = new New_sp();
                nw.sp_Apply_Selected_function_into_system_New
                (
                    Connection_SQL._division,
                    Connection_SQL._fmkey,
                    _list_id_function,
                    _list_id_signature_All,
                    _list_selected,
                    typeview_
                );
                if (nw.b_success == "1")
                {

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
        private void chkSelected_CheckedChanged(object sender, EventArgs e)
        {
            if (chkSelected.Checked)
            {
                //foreach (DataRow dr in dt_list_function.Rows) // search whole table
                //{
                //    dr["Selected"] = 1;
                //}
                load_List_function_active("ALL");
            }
            else
            {
                //foreach (DataRow dr in dt_list_function.Rows) // search whole table
                //{
                //    dr["Selected"] = 0;
                //}
                load_List_function_active("");
            }
        }
        private void CmdSave_Click(object sender, EventArgs e)
        {
            try
            {
                if (cls_function.Check_user_action())
                {
                    int _count_line_process = 0;
                    string _typeview = "";

                    for (int i = 0; i < dataGridView1.Rows.Count; i++)
                    {
                        DataGridViewRow row = dataGridView1.Rows[i];
                        if (bool.Parse(row.Cells["Selected"].Value.ToString()))
                        {
                            _count_line_process += 1;
                        }
                    }

                    if (_count_line_process == dataGridView1.RowCount)
                    {
                        _typeview = "";
                    }
                    else
                    {
                        _typeview = "re-gen";
                    }
                    Apply_selected_to_system(_typeview);

                    New_sp nw1 = new New_sp();
                    nw1.sp_Gen_WF_New3
                    (
                        Connection_SQL._division,
                        Connection_SQL._fmkey,
                        _typeview//GEN
                    );
                    if (nw1.b_success == "1")
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n [Gen FC]-->Successfully.../";
                        //filter_config
                        Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("filter_config");
                        //refresh ALl wf
                        Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
                    }
                    else
                    {
                        txtprocessStatus.Text = txtprocessStatus.Text + "\n [Gen FC]-->" + nw1.c_errmsg;
                        MessageBox.Show(nw1.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            catch (Exception ex)
            {
                txtprocessStatus.Text = txtprocessStatus.Text + "\n [Gen FC]-->" + ex.Message;
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            LbProcessing.Visible = false;
        }

        private void FrmRe_GenPartial_WF_FormClosed(object sender, FormClosedEventArgs e)
        {

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }



        private void button1_Click(object sender, EventArgs e)
        {

        }

        private void refreshWFToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_by_Type_view_Unit");
        }

        private void justRefreshWFFCALLColumnToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //refresh ALl wf
            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
        }

        private void testSignatureToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Apply_selected_to_system("re-gen");
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //if (e.ColumnIndex == 0)
            //{
            //    dataGridView1.SelectedRows[e.RowIndex + 1].Selected = true;
            //}
        }

        private void dataGridView1_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            for (int i = 6; i < (_total_signature + 6 - 1); i++)
            {
                if (e.ColumnIndex == 0)
                {
                    //MessageBox.Show(dataGridView1.Rows[e.RowIndex].Cells[0].Value.ToString());
                    if (bool.Parse(dataGridView1.Rows[e.RowIndex].Cells[0].Value.ToString()) == true)
                    {
                        //MessageBox.Show(e.ColumnIndex.ToString());
                        dataGridView1[i, e.RowIndex].Value = true;
                    }
                    else
                    {
                        dataGridView1[i, e.RowIndex].Value = false;
                    }
                }

            }
        }

        private void CmdCancel_Click(object sender, EventArgs e)
        {
            allowClose = true;
            this.Close();
            ////filter_config
            //Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("filter_config");
            ////refresh ALl wf
            //Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
        }

        private void FrmRe_GenPartial_WF_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Allow close button (X) to work by setting allowClose to true when user clicks X
            if (e.CloseReason == CloseReason.UserClosing)
            {
                allowClose = true;
            }

            if (!allowClose)
                e.Cancel = true;
        }

        private void cmdSave_Enter(object sender, EventArgs e)
        {
            txtprocessStatus.Text = "Processing.../";
            LbProcessing.Visible = true;
        }
    }
}
