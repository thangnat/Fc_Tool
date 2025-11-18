using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;
using System.Windows.Forms;
using DevExpress.XtraEditors;
using DevExpress.XtraRichEdit.Model;

namespace WinFormsApp2
{
    public partial class FrmReport : XtraForm//Form
    {
        public static DataTable dt_report = new DataTable();
        public static string _report_type = string.Empty;
        public static DataTable dt_config = new DataTable();
        public static string _report_name = string.Empty;
        public FrmReport()
        {
            InitializeComponent();
            //_type_report = Type_;
            this.StartPosition = FormStartPosition.CenterScreen;
            load_config();
            //Load_grid();
            Load_report_type();
        }

        void load_config()
        {
            string sql = string.Empty;
            sql = @"select [Report Name],[SQL Script] from V_FC_REPORT_TYPE";
            dt_config = Connection_SQL.GetDataTable(sql);

        }
        void Load_report_type()
        {
            DataTable dt = new DataTable();
            //dt.Columns.Add("Compare list", typeof(string));
            //dt.Rows.Add("=");
            //dt.Rows.Add("<>");
            //dt.Rows.Add(">");
            //dt.Rows.Add(">=");
            //dt.Rows.Add("<");
            //dt.Rows.Add("<=");
            string sql = string.Empty;
            sql = @"select [Report Name] from V_FC_REPORT_TYPE";
            dt = Connection_SQL.GetDataTable(sql);

            gleReportType.Properties.DataSource = dt;
            gleReportType.Properties.DisplayMember = "Report Name";
            gleReportType.Properties.ValueMember = "Report Name";
            //GLCompareList.Properties.TextEditStyle = DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor;
            gleReportType.Properties.TextEditStyle = DevExpress.XtraEditors.Controls.TextEditStyles.Standard;
            gleReportType.EditValue = "";
            gleReportType.Properties.TextEditStyle = DevExpress.XtraEditors.Controls.TextEditStyles.DisableTextEditor;
        }
        //void Load_grid()
        //{
        //    string sql = string.Empty;
        //    if (_type_report == "SO_FC")
        //    {
        //        sql = @"select * from V_FC_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + "_SO_FORECAST";
        //    }
        //    else if (_type_report == "SO_ACTUAL")
        //    {
        //        sql = @"SELECT * FROM V_FC_" + Connection_SQL._division + "_SO_HIS_FINAL";
        //    }

        //    dt_report = Connection_SQL.GetDataTable(sql);
        //    gridControl1.DataSource = dt_report;
        //    gridControl1.ForceInitialize();
        //    gridView1.BestFitColumns();
        //}

        private void groupControl1_CustomButtonClick(object sender, DevExpress.XtraBars.Docking2010.BaseButtonEventArgs e)
        {
            try
            {
                cls_function.ExportExcelFile_GridControl(gridControl1, _report_name+".xlsx");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdLoadData_Click(object sender, EventArgs e)
        {
            try
            {
                cls_function.start_loading("");
                _report_name = gleReportType.Text;
                DataTable dt_search = new DataTable();
                string _sql_script = string.Empty;
                string _sql_script_ok = string.Empty;
                dt_search = Connection_SQL.GetDataTable(@"select * from V_FC_REPORT_TYPE where [Report Name]='" + _report_name + "'");
                if (dt_search.Rows.Count > 0)
                {
                    _sql_script = dt_search.Rows[0]["SQL Script"].ToString();
                }
                _sql_script_ok = _sql_script.Replace("@DIVISION", Connection_SQL._division).Replace("@FM_KEY", Connection_SQL._fmkey);
                dt_report = Connection_SQL.GetDataTable(_sql_script_ok);
                if (dt_report.Rows.Count == 0)
                {
                    gridControl1.DataSource = null;
                    gridView1.Columns.Clear();
                }
                else
                {
                    gridControl1.DataSource = null;
                    gridView1.Columns.Clear();
                    gridControl1.DataSource = dt_report;
                    gridControl1.ForceInitialize();
                    gridView1.BestFitColumns();
                }
            }
            catch (Exception ex)
            {
                cls_function.end_loading();
                MessageBox.Show(ex.Message,"[Loreal VN]",MessageBoxButtons.OK,MessageBoxIcon.Stop);
            }
            cls_function.end_loading();            
        }
    }
}
