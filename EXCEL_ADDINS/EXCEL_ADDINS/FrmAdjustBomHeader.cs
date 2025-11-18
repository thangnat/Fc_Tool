using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.OleDb;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Office.Interop.Access.Dao;

namespace EXCEL_ADDINS
{
    public partial class FrmAdjustBomHeader : Form
    {
        public string _division = string.Empty;
        public string _fmkey = string.Empty;
        public string _subgrp = string.Empty;
        public string _BundleCode = string.Empty;
        public string _Channel = string.Empty;
        public string _columnName = string.Empty;
        public string _columnValue = "0";
        public static string _list_search_text = string.Empty;
        public static string _sp_name = "sp_FC_GetData_AdjustBom_New2";
        
        public FrmAdjustBomHeader()
        {
            InitializeComponent();

            _division = Connection_SQL._division.Trim();
            _fmkey = Connection_SQL._fmkey.Trim().Replace("-", "");
            _subgrp = Connection_SQL._subgrp.Trim();
            _list_search_text = _subgrp;
            GrpListSubgrp.Visible = false;

            New_sp nw = new New_sp();
            nw.sp_FC_Create_Bomheader_Tmp
            (
                _division    
            );
            if (nw.b_success == "0")
            {
                MessageBox.Show("Không tạo được bản tạm cho [Bom Header] \n vui lòng liên hệ team PIM...!", mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            Load_dataGrid("");
        }

        void Load_dataGrid(string subgrp_)
        {
            _subgrp = subgrp_;
            DataTable dt = new DataTable();
            ArrayList array_param = new ArrayList() { "@Division", "@FM_KEY", "@Searchvalue" };
            ArrayList array_value = new ArrayList() { _division.Trim(), _fmkey.Trim().Replace("-", ""), _subgrp.Trim() };//"BC AA SALICYLIC GEL WASH 120ML"

            dt = Connection_SQL.Exec_StoreProc_datatable_Admin(_sp_name, array_param, array_value);
            dataGridView1.DataSource = dt;
            dataGridView1.Columns[1].Width = 300;
            dataGridView1.AllowUserToAddRows = false;
        }

        private void dataGridView1_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                int columnIndex = dataGridView1.CurrentCell.ColumnIndex;
                int rowIndex = dataGridView1.CurrentCell.RowIndex;
                _columnName = dataGridView1.Columns[columnIndex].Name;
                _columnValue = dataGridView1.CurrentCell.Value.ToString();
                _BundleCode = dataGridView1.Rows[rowIndex].Cells[0].FormattedValue.ToString();
                _Channel = dataGridView1.Rows[rowIndex].Cells[2].FormattedValue.ToString();
                New_sp nw = new New_sp();
                nw.sp_Update_Bom_Header_New
                (
                    _division,
                    _fmkey,
                    _Channel,//channel
                    _BundleCode,//Bundle code
                    _columnName,//CollumnName
                    _columnValue//Value
                );
                if (nw.b_success == "1")
                {

                }
                else
                {
                    MessageBox.Show(nw.c_errmsg, mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }

        }
        //void Load_Data()
        //{
        //    _subgrp = txtSearch.Text;
        //    Load_dataGrid();
        //    dataGridView1.Focus();
        //}        

        private void dataGridView1_DoubleClick(object sender, EventArgs e)
        {
            if (_BundleCode.Length > 0)
            {
                FrmComponentBom frm = new FrmComponentBom(_BundleCode);
                frm.StartPosition = FormStartPosition.CenterScreen;
                frm.ShowDialog();
            }
            else
            {
                MessageBox.Show("Bundle code ise null.../", mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void dataGridView1_Click(object sender, EventArgs e)
        {
            try
            {
                int columnIndex = dataGridView1.CurrentCell.ColumnIndex;
                int rowIndex = dataGridView1.CurrentCell.RowIndex;
                _columnName = dataGridView1.Columns[columnIndex].Name;
                _columnValue = dataGridView1.CurrentCell.Value.ToString();
                //_BundleCode = dataGridView1.Rows[rowIndex].Cells[0].FormattedValue.ToString();

                if (rowIndex >= 0)
                {
                    _BundleCode = dataGridView1.Rows[rowIndex].Cells[0].FormattedValue.ToString();
                }
                else
                {
                    _BundleCode = "";
                }
            }
            catch(Exception ex)
            {
                MessageBox.Show(ex.Message, mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            
        }

        private void cmdSubmit_Click(object sender, EventArgs e)
        {

        }


        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            
        }

        private void dataGridView2_DoubleClick(object sender, EventArgs e)
        {
            string _SearchValue = string.Empty;
            try
            {
                //int columnIndex = dataGridView2.CurrentCell.ColumnIndex;
                int rowIndex = dataGridView2.CurrentCell.RowIndex;
                //_columnName = dataGridView1.Columns[columnIndex].Name;
                //_BundleCode = dataGridView1.Rows[rowIndex].Cells[0].FormattedValue.ToString();

                if (rowIndex >= 0)
                {
                    _SearchValue = dataGridView2.Rows[rowIndex].Cells[0].FormattedValue.ToString();
                }
                else
                {
                    _SearchValue = "";
                }
            }
            catch (Exception ex)
            {
                _SearchValue = "";
                MessageBox.Show(ex.Message, mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            //_subgrp = _SearchValue;
            if (_SearchValue.Length > 0)
            {
                txtSearch.Text = _SearchValue;
                //Load_dataGrid(_SearchValue);
            }
            else
            {
                txtSearch.Text = "";
                //dataGridView1.DataSource = null;
            }
            GrpListSubgrp.Visible = false;
            dataGridView1.Focus();
        }

        private void FrmAdjustBomHeader_Load(object sender, EventArgs e)
        {
            
        }

        private void button1_Click(object sender, EventArgs e)
        {
            GrpListSubgrp.Visible = false;
        }

        private void label2_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            GrpListSubgrp.Visible = false;
        }

        private void cmdApply_Click(object sender, EventArgs e)
        {
            //Load_dataGrid("");
            int _rows_selected = 0;
            //string _result_ok = string.Empty;
            string _result = string.Empty;
            for (int i = 0; i < dataGridView2.Rows.Count; i++)
            {
                DataGridViewRow row = dataGridView2.Rows[i];
                
                if (Convert.ToBoolean(row.Cells["Selected"].Value) == true)
                {
                   
                    if (_result.Length == 0)
                    {
                        _result = row.Cells["Result"].Value.ToString();
                    }
                    else
                    {
                        _result = _result+","+row.Cells["Result"].Value.ToString();
                    }
                    //_result_ok = _result_ok + "," + _result;
                }
                _rows_selected = _rows_selected + 1;
            }
            GrpListSubgrp.Visible = false;
            //MessageBox.Show(_result);
            Load_dataGrid(_result);
            //txtSearch.Text = _result;
            
        }

        private void txtSearch_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                try
                {
                    if (txtSearch.Text.Length > 0)
                    {
                        GrpListSubgrp.Visible = true;
                        DataTable dt = new DataTable();
                        ArrayList array_param = new ArrayList() { "@Division", "@Searchtext" };
                        ArrayList array_value = new ArrayList() { _division.Trim(), txtSearch.Text };

                        dt = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_FC_GetList_Subgroup", array_param, array_value);
                        dataGridView2.DataSource = dt;
                        dataGridView2.Columns[0].Width = 50;
                        dataGridView2.Columns[1].Width = 500;
                        dataGridView2.AllowUserToAddRows = false;
                    }
                    else
                    {
                        Load_dataGrid("");
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }
    }
}
