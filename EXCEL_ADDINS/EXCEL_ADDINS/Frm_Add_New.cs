using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public partial class Frm_Add_New : Form
    {
        public static DataTable dt_source = null;
        public static DataTable dt_destination = null;
        public static string _subgrp = string.Empty;
        public static string _subgrp_del = string.Empty;
        public Frm_Add_New()
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterScreen;
            get_subgrp("s");
            get_subgrp("d");
        }

        public void get_subgrp(string type_)
        {
            ArrayList array_param = new ArrayList() { "@Division", "@FM_KEY", "@type" };
            ArrayList array_value = new ArrayList() { Connection_SQL._division,Connection_SQL._fmkey, type_ };
            if (type_.ToUpper() == "S")
            {
                dt_source = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_get_list_subgrp", array_param, array_value);
                dataGridView1.DataSource = dt_source;
                dataGridView1.Columns[0].Width = 300;
                dataGridView1.AllowUserToAddRows = false;
            }
            else if (type_.ToUpper() == "D")
            {
                dt_destination = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_get_list_subgrp", array_param, array_value);
                dataGridView2.DataSource = dt_destination;
                dataGridView2.Columns[0].Width = 300;
                dataGridView2.AllowUserToAddRows = false;
            }
        }

        public void get_subgrp()
        {
            ArrayList array_param = new ArrayList() { "@Division" };
            ArrayList array_value = new ArrayList() { Connection_SQL._division };

            dt_source = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_get_list_subgrp", array_param, array_value);
            dataGridView1.DataSource = dt_source;
            dataGridView1.Columns[0].Width = 300;
            dataGridView1.AllowUserToAddRows = false;

        }
        private void cmdSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                if (cls_function.Check_user_action())
                {
                    DialogResult drl = MessageBox.Show("Do you want to add more line on WF?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                    if (drl == DialogResult.Yes)
                    {
                        New_sp nw = new New_sp();
                        nw.sp_FC_FM_Original_Add_More_NEW
                        (
                            Connection_SQL._division,
                            Connection_SQL._fmkey,
                            "1"
                        );
                        if (nw.b_success == "1")
                        {
                            //filter_config
                            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("filter_config");
                            //refresh ALl wf
                            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
                            MessageBox.Show("Add list [SUB GROUP/ Brand] successfully.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        else
                        {
                            MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                }
                else
                {
                    MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void dataGridView1_DoubleClick(object sender, EventArgs e)
        {
            try
            {
                //MessageBox.Show(_subgrp);
                if (_subgrp.Length > 0)
                {
                    New_sp nw1 = new New_sp();
                    nw1.sp_select_Forecasting_Line
                    (
                        Connection_SQL._division,
                        _subgrp,
                        "s"
                    );
                    if (nw1.b_success == "1")
                    {
                        get_subgrp("d");
                        get_subgrp("s");
                    }
                    else
                    {
                        MessageBox.Show(nw1.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    MessageBox.Show("[SUB GROUP/ Brand] should be not null.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            _subgrp = "";
            try
            {   
                _subgrp = dataGridView1.Rows[e.RowIndex].Cells[0].Value.ToString();
            }
            catch
            {

            }
        }

        private void dataGridView2_DoubleClick(object sender, EventArgs e)
        {
            try
            {
                if (_subgrp_del.Length > 0)
                {
                    New_sp nw = new New_sp();
                    nw.sp_select_Forecasting_Line
                    (
                        Connection_SQL._division,
                        _subgrp_del,
                        "d"
                    );
                    if (nw.b_success == "1")
                    {
                        get_subgrp("d");
                        get_subgrp("s");
                    }
                    else
                    {
                        MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    MessageBox.Show("[SUB GROUP/ Brand] should be not null.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void dataGridView2_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            _subgrp_del = "";
            try
            {
                _subgrp_del = dataGridView2.Rows[e.RowIndex].Cells[0].Value.ToString();
            }
            catch
            {

            }
        }

        private void txtSubgrp_TextChanged(object sender, EventArgs e)
        {
            try
            {
                string searchString = "";
                if (txtSubgrp.Text.Length > 0)
                {
                    //dataGridView1.DataSource = dt_source.DefaultView.RowFilter = " SUB GROUP/ Brand Like '%" + txtSubgrp.Text.Trim() + "%'";
                    searchString = String.Format("[SUB GROUP/ Brand] LIKE '%{0}%'", txtSubgrp.Text.Trim());
                    if (searchString != "")
                    {
                        DataView dv = new DataView(dt_source);
                        dv.RowFilter = searchString;
                        DataTable tab = dv.ToTable();
                        dataGridView1.DataSource = tab;
                        dataGridView1.AllowUserToAddRows = false;
                    }
                }
                else
                {
                    get_subgrp("s");
                }
            }
            catch
            { 
            
            }
        }
    }
}
