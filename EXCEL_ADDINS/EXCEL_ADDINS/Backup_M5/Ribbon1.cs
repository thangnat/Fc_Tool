
using Microsoft.Office.Tools.Ribbon;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
//using Excel = Microsoft.Office.Interop.Excel;

namespace EXCEL_ADDINS
{

    public partial class Ribbon1
    {
        //public static string sUSerID = "admin1";
        public static string serverName = "10.240.65.33";
        Cls_Main cls_main = new Cls_Main();
        Cls_BaseSys cls_sys = new Cls_BaseSys();
        //DataTable _dt_filename = null;
        //Function fn = new Function();
        private void Ribbon1_Load(object sender, RibbonUIEventArgs e)
        {
            SetConnectionAll();
            //bool _result = true;
            //string _fc_version_guid = "";
            //Microsoft.Office.Interop.Excel.Worksheet ws = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.ActiveSheet;
            //_fc_version_guid = ws.Range["B1"].ToString();

            //if (Properties.Settings.Default.FC_Version_Guid != _fc_version_guid)
            //{
            //    _result = false;
            //    EnableControl(false);
            //}
            //DataTable dt_hostname = new DataTable();
            //if (_result)
            //{
            //    string _hostname = Environment.MachineName;
            //    //get usernane from computername
            //    dt_hostname = Connection_Access.Truyvan_Access(@"select * from HOSTNAME where HostName = '" + _hostname + "'");
            //    if (dt_hostname.Rows.Count <= 0)
            //    {
            //        _result = false;
            //        cmd_Import_Historical_Data.Enabled = false;
            //        Cmd_Import_Master_Data.Enabled = false;
            //        MessageBox.Show("Pls click button [Refresh HostName] to Update HostName", mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            //    }
            //}
            //if(_result)
            //{
            //    Program.gsServerName = serverName;
            //    Program.gsAccount = dt_hostname.Rows[0]["UserName"].ToString();
            //    Program.gsUserID = dt_hostname.Rows[0]["UserName"].ToString();
            //    Program.gsConnectionString = "Data Source=" + Program.gsServerName + ";Initial Catalog=SC2;User ID=" + Program.gsUserID + ";Password=sgl789;Connect Timeout=3600000";
            //}
            //if (_result)
            //{
            //    _result = cls_main.ConnectDataBase();
            //}
            //if (_result)
            //{
            //    EnableControl(true);
            //    SetConnectionAll();
            //}
            //else
            //{
            //    EnableControl(false);
            //    MessageBox.Show(cls_main.err_Main, mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            //}
        }
        //void EnableControl(bool _enable)
        //{
        //    cmd_Import_Historical_Data.Enabled = _enable;
        //    Cmd_Import_Master_Data.Enabled = _enable;
        //}
        public void SetConnectionAll()//string sFormName, string sClassName, Form frm)
        {
            //-----------------------------------------------------------------
            Cls_BaseSys Cls_basesys = new Cls_BaseSys();
            Cls_basesys.PhanHanh = Program.gnPhanHanh;
            Cls_basesys.Right = Program.gsRight;
            Cls_basesys.ConnectionString = Program.gsConnectionString_admin;
            Cls_basesys.CnConnect = Program.gcnConnect;
            Cls_basesys.Account = Program.gsUserID;
            Cls_basesys.UserName = Program.gsUserName;
            Cls_basesys.SourcePath = Program.gsSourcePath;
            Cls_basesys.ApplicationPath = Program.gsApplicationPath;
            Cls_basesys.SanPhamPath = Program.gsSanPhamPath;
            Cls_basesys.GDate = Program.gsDate;
            Cls_basesys.GTime = Program.gsTime;
            Cls_basesys.UserID = Program.gsUserID;
            Cls_basesys.MaPB = Program.gnMaPB;
            Cls_basesys.gsCompanyCode = Program.gsCompanyCode;
            //cls_hamtutao._promt = "Please waiting a second.....";
        }

        private void cmd_Import_Historical_Data_Click(object sender, RibbonControlEventArgs e)
        {

            //FrmTest frm = new FrmTest();
            //frm.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            //frm.ShowDialog();
        }

        private void CmdRefreshHostName_Click(object sender, RibbonControlEventArgs e)
        {
            //FrmTest frm = new FrmTest();
            //frm.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            //frm.ShowDialog();
            //try
            //{
            //    string _sp_name = "sp_GetHostName";
            //    ArrayList array_param = new ArrayList() { };
            //    ArrayList array_value = new ArrayList() { };
            //    DataTable dt = new DataTable();

            //    dt = cls_sys.Exec_StoreProc_datatable_Admin("sp_GetHostName", array_param, array_value);
            //    fn.BulkExportToAccess(_sp_name, "HOSTNAME", dt);
            //    EnableControl(true);
            //}
            //catch (Exception ex)
            //{
            //    EnableControl(false);
            //    MessageBox.Show(ex.Message,mod_BaseSys.gsCompanyCode,MessageBoxButtons.OK,MessageBoxIcon.Stop);
            //}
        }
        public void ExecuteExcelMacro()// string sourceFile)
        {
            //string _filepath = @"L:\FC_WORKING_FILE.xlsm";
            //Excel.Application excellapp = new Excel.Application();
            //Excel.Workbook wb = excellapp.Workbooks.Open(_filepath, ReadOnly: false);
            //try
            //{
            //    excellapp.Visible = false;
            //    excellapp.Run("test1");
            //}
            //catch (Exception ex)
            //{   
            //    MessageBox.Show(ex.Message);
            //}
            //wb.Close(false);excellapp.Application.Quit();
            //excellapp.Quit();
        }

        private void CmdOpenWF_Click(object sender, RibbonControlEventArgs e)
        {
            //string _pathfile = string.Empty;
            //DataTable dt = new DataTable();
            //string _sql = @"select Pathfile = isnull(Config1,'')
            //            from SysConfigValue (NOLOCK)
            //            where ConfigHeaderID = 24
            //            and cast(isnull(Config2,'0') as int) = 1";
            //dt = cls_sys.GetDataTable(_sql);
            //if (dt!= null)
            //{
            //    _pathfile = dt.Rows[0]["Pathfile"].ToString();
            //}
            //if (_pathfile.Length > 0)
            //{
            //    Open_Excel_WF(_pathfile);
            //    //////string _filepath = this.Base.st+ @"\FC_WORKING_FILE.xlsm";
            //    ////Excel.Application excellapp = new Excel.Application();
            //    ////Excel.Workbook wb = excellapp.Workbooks.Open(_pathfile, ReadOnly: false);
            //    ////excellapp.Visible = true;
            //    //Excel.Application excel = new Excel.Application();
            //    //Excel.Workbook wb = excel.Workbooks.Open(_pathfile);
            //    //excel.Visible = true;
            //}
            //else
            //{
            //    MessageBox.Show("No find path or pathfile is null", mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            //}
        }
        void Open_Excel_WF(string pathfile)
        {
            //Excel.Application excel;
            //Excel.Workbook wbexcel;
            //bool wbexists;
            //Excel.Worksheet objsht;
            //Excel.Range objrange;

            //string _pathfile = string.Empty;
            //DataTable dt = new DataTable();
            //string _sql = @"select Pathfile = isnull(Config1,'')
            //            from SysConfigValue (NOLOCK)
            //            where ConfigHeaderID = 24
            //            and cast(isnull(Config2,'0') as int) = 1";
            //dt = cls_sys.GetDataTable(_sql);
            //if (dt != null)
            //{
            //    _pathfile = dt.Rows[0]["Pathfile"].ToString();
            //}

            //Excel.Application excel = new Excel.Application();
            //Excel.Workbook wb = excel.Workbooks.Open(pathfile);
            //excel.Visible = true;
            ////FileInfo fi = new FileInfo(pathfile);
            ////if (fi.Exists)
            ////{
            ////    System.Diagnostics.Process.Start(pathfile);
            ////}
            ////else
            ////{
            ////    MessageBox.Show("No find path or pathfile is null", mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            ////    //file doesn't exist
            ////}
        }

        private void CmdTaskPane_Click(object sender, RibbonControlEventArgs e)
        {
            ThisAddIn._myCustomTaskPane.Visible = true;
        }

        private void Cmd_Import_Master_Data_Click(object sender, RibbonControlEventArgs e)
        {
            //Connection_SQL.KetnoiCSDL_SQL();
            //FrmIGrid frm = new FrmIGrid();
            //frm.StartPosition = FormStartPosition.CenterScreen;
            //frm.ShowDialog();

            //Process.Start(@"C:\phuongho\PROJECT\DESIGN\CSharp\IMPORT_SC\IMPORT_SC\bin\Debug\IMPORT_SC.exe");
        }
        //private void button2_Click(object sender, RibbonControlEventArgs e)
        //{
        //    ExecuteExcelMacro();// @"C:\phuongho\PROJECT\DESIGN\CSharp\FC\FC_Addins\EXCEL_ADDINS\bin\Debug\FC_WORKING_FILE.xlsm");
        //}
    }
}
