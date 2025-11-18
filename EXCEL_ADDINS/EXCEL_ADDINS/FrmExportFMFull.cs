//using Microsoft.VisualBasic;
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
//using H2T_BaseSys;
//using Excel = Microsoft.Office.Interop.Excel;

namespace EXCEL_ADDINS
{
    public partial class FrmExportFMFull : Form
    {
        Cls_BaseSys cls_sys = new Cls_BaseSys();

        public static string _sp_name = "sp_FC_EXPORT_TO_FM";
        public string _division = string.Empty;
        public string _fmkey = string.Empty;
        public string _timeseries = string.Empty;
        public string _folder_path = string.Empty;
        public static DataTable dt = null;
        public static string _channel = string.Empty;
        private int desiredStartLocationX;
        private int desiredStartLocationY;
        public FrmExportFMFull()//string division_, string fmkey_)
        {
            InitializeComponent();
            _division = Connection_SQL._division;
            _fmkey = Connection_SQL._fmkey;
            _folder_path= @"\\10.240.65.43\loreal\10_PUBLIC\03_SAPData\SC_IMPORT\Archive\FORECAST\" + _division + @"\FM_Template_Upload\FM_Final\";
            Load_dataGridview1();
            rONLINE.Checked = true;
        }
        public FrmExportFMFull(int x, int y) : this()
        {
            this.desiredStartLocationX = x;
            this.desiredStartLocationY = y;

            Load += new EventHandler(FrmExportFMFull_Load);
        }
        private void FrmExportFMFull_Load(object sender, EventArgs e)
        {
            this.SetDesktopLocation(desiredStartLocationX, desiredStartLocationY);
        }
        void Load_dataGridview1()
        {   
            string _sql = @"Select Selected,Description from V_FC_EXPORT_FM_TYPE Order by [Row_number] asc";
            dt = Connection_SQL.GetDataTable(_sql);
            dataGridView1.DataSource = dt;
            dataGridView1.AllowUserToAddRows = false;
        }
        void Get_FM_Template(string _timeseries)
        {
            DataTable dt = new DataTable();
            //_sp_name = "sp_Get_SellIn";
            ArrayList array_param = new ArrayList() { "@Division", "@FM_KEY", "@Channel", "@Timeseries", "@subgrp" };
            ArrayList array_value = new ArrayList() { _division, _fmkey,_channel, _timeseries,"" };

            dt = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_FC_EXPORT_TO_FM_VIEW", array_param, array_value);


            dataGridView2.DataSource = dt;
            dataGridView2.Columns[4].Width = 300;
            dataGridView2.AllowUserToAddRows = false;
        }

        private void cmdSubmit_Click(object sender, EventArgs e)
        {
            int _rows_selected = 0;
            for (int i = 0; i < dataGridView1.Rows.Count-1; i++)
            {
                DataGridViewRow row = dataGridView1.Rows[i];
                string _timeseries_ok = string.Empty;
                if (Convert.ToBoolean(row.Cells["Selected"].Value) == true)
                {
                    _timeseries_ok = row.Cells["Description"].Value.ToString();
                    txtTimseries.Text = _timeseries_ok;
                    //MessageBox.Show(row.Cells["Description"].Value.ToString());
                    //Get_FM_Template(row.Cells["Description"].Value.ToString());
                    //GetDATA(_timeseries_ok);
                    Export_Excel_by_SQL(_timeseries_ok);
                    _rows_selected = _rows_selected + 1;
                }
            }
            string _promt = "Export Excel file(" + _rows_selected.ToString() + " files) successfully.../\n "
                        + "pls check folder: ";
            FrmInputMessage frm = new FrmInputMessage(_promt,_folder_path);
            frm.ShowDialog();
            //string input = Interaction.InputBox(_promt, "Loreal VN", _folder_path, 10, 10);
            //MessageBox.Show("Export Excel file("+_rows_selected.ToString()+" files) successfully.../\n "
            //            + "pls check folder: " + _folder_path, ,
            //            MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        void GetDATA(string _timeseries)
        {
            //_timeseries_ok = row.Cells["Description"].Value.ToString();
            //txtTimseries.Text = _timeseries_ok;
            //MessageBox.Show(row.Cells["Description"].Value.ToString());
            Get_FM_Template(_timeseries);
        }
        void Export_Excel_by_SQL(string _timeseries)
        {
            try
            {
                New_sp nw = new New_sp();
                nw.sp_FC_FM_Export_Excel_File_OK
                (
                    _division,
                    _fmkey,
                    _timeseries,
                    ""
                );
                if (nw.b_success == "1")
                {
                    //MessageBox.Show("export successed.../", "L'Oreal", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show(nw.c_errmsg, "L'Oreal", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message,"L'Oreal",MessageBoxButtons.OK,MessageBoxIcon.Stop);
            }
            
        }
        private void button1_Click(object sender, EventArgs e)
        {
           
        }
        private void releaseObject(object obj)
        {
            try
            {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
                obj = null;
            }
            catch (Exception ex)
            {
                obj = null;
                MessageBox.Show("Exception Occured while releasing object " + ex.ToString());
            }
            finally
            {
                GC.Collect();
            }
        }

        private void cmdView_Click(object sender, EventArgs e)
        {
            //MessageBox.Show();
            GetDATA(_timeseries);
        }   

        private void dataGridView1_Click(object sender, EventArgs e)
        {
            DataGridViewRow row = dataGridView1.Rows[dataGridView1.CurrentRow.Index];
            _timeseries = row.Cells["Description"].Value.ToString();
            txtTimseries.Text = _timeseries;
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void ChkSelectedAll_CheckedChanged(object sender, EventArgs e)
        {
            if (ChkSelectedAll.Checked)
            {
                foreach (DataRow dr in dt.Rows) // search whole table
                {
                    dr["Selected"] = 1;
                }
            }
            else
            {
                foreach (DataRow dr in dt.Rows) // search whole table
                {
                    dr["Selected"] = 0;
                }
            }
        }

        private void rONLINE_CheckedChanged(object sender, EventArgs e)
        {
            if(rONLINE.Checked)
            {
                _channel = "ONLINE";
            }            
        }

        private void rOFFLINE_CheckedChanged(object sender, EventArgs e)
        {
            if (rOFFLINE.Checked) {
                _channel = "OFFLINE";
            }
        }

        private void txtTimseries_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
