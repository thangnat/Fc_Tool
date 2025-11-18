using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
using Microsoft.Office.Tools.Excel;
using System.Data;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public partial class ThisAddIn
    {
        // User control
        private System.Windows.Forms.UserControl _usr;
        
        // Custom task pane
        public static Microsoft.Office.Tools.CustomTaskPane _myCustomTaskPane;
        private void ThisAddIn_Startup(object sender, System.EventArgs e)
        {          
            //Create an instance of the user control
            _usr = new UTaskPane();
            
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf("FC_WORKING_FILE") >= 0)
            {
                Microsoft.Office.Interop.Excel.Worksheet sys = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.Worksheets["SysConfig"];
                sys.Activate();
                Connection_SQL._Accesspath = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B39"].Text;
                Connection_SQL._fullname = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B16"].Text;
                Connection_SQL._server_name= Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B46"].Text;
                Connection_SQL._Database_name = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B45"].Text;
                //Program.gsServerName = Connection_SQL._server_name;
                //Program.gsDatabaseName = Connection_SQL._Database_name;
            }
            else
            {
                Connection_SQL._Accesspath = "";
                Connection_SQL._fullname = "";
                Connection_SQL._server_name = "";
                Connection_SQL._Database_name = "";
                //Program.gsServerName = "";
                //Program.gsDatabaseName = "";
            }
            // Connect the user control and the custom task pane 
            _myCustomTaskPane = CustomTaskPanes.Add(_usr, "Forecasting Tool ["+ Connection_SQL._version_exe + "] || Tên người dùng: " + Connection_SQL._fullname + "|| Thời gian bắt đầu: " + DateTime.Now.ToString()+" ||Server Name:"+Connection_SQL._server_name+" ||Database name: "+Connection_SQL._Database_name);

            DataTable dt_user_permission = new DataTable();
            dt_user_permission = Connection_SQL.GetDataTable(@"select * from V_FC_CONFIG_USER_ALLOW where active = 1 and userid = '" + Connection_SQL._userID + "' and Division = '" + Connection_SQL._division + "'");
            if ((dt_user_permission.Rows.Count == 0 || dt_user_permission == null) && cls_function.priority_ == false)
            {
                MessageBox.Show("User [" + Connection_SQL._userID + "] not permission.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }
            else
            {
                _myCustomTaskPane.Visible = true;
                _myCustomTaskPane.DockPosition = Microsoft.Office.Core.MsoCTPDockPosition.msoCTPDockPositionTop;                
                _myCustomTaskPane.Height = 90;

            }
            Microsoft.Office.Interop.Excel.Worksheet ws_wf = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.Worksheets["WF"];
            ws_wf.Activate();
            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("show_formular_bar");
            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Hide_formular_bar");

            //MessageBox.Show("ABC");
            check_version();
        }
        public void check_version()
        {
            try
            {
                double _deadline_date = 0;
                double _deadline_time = 0;

                DataTable dt_ver = new DataTable();
                dt_ver = Connection_SQL.GetDataTable(@"select [Version],[Content] from V_FC_VERSION_EXE");


                if (Connection_SQL._version_exe != dt_ver.Rows[0]["Version"].ToString())
                {
                    DataTable dt_deadline = new DataTable();
                    dt_deadline = Connection_SQL.GetDataTable(@"select [Day]=cast(format(Time_Update,'yyyyMMdd') as numeric),[Deadline]=(cast(format(Time_Update,'HH') as int)*60*60+cast(format(Time_Update,'HH') as int)*60) 
                                                                from DM_NhanVien (NOLOCK)
                                                                where MaNV='" + Connection_SQL._userID + "'");

                    if (dt_deadline.Rows.Count > 0)
                    {
                        _deadline_date = double.Parse(dt_deadline.Rows[0]["Day"].ToString());
                        _deadline_time = double.Parse(dt_deadline.Rows[0]["Deadline"].ToString());
                    }
                    if
                    (
                        double.Parse(DateTime.Now.ToString("yyyyMMdd")) >= _deadline_date
                            && (DateTime.Now.Hour * 60 * 60 + DateTime.Now.Minute * 60) >= _deadline_time
                    )
                    {
                        if (!cls_function.Check_form_is_open("FrmUpdate_Version"))
                        {
                            FrmUpdate_Version frm1 = new FrmUpdate_Version(dt_ver.Rows[0]["Content"].ToString());
                            frm1.StartPosition = FormStartPosition.CenterScreen;
                            frm1.ShowDialog();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
        private void _usr_PreviewKeyDown(object sender, PreviewKeyDownEventArgs e)
        {
            
        }

        //public void EnableShortCut()
        //{
        //    Microsoft.Office.Interop.Excel.Application app = Globals.ThisAddIn.Application;
        //    app.OnKey("+^{U}", ""); //action A1 should be performed when user clicks  Ctrl + Shift + U
        //                            //app.OnKey("+^{L}", "ATwo");//action A2 should be performed when user clicks  Ctrl + Shift + L
        //                            //app.OnKey("+^{P}", "AThree"); //action A3 should be performed when user clicks  Ctrl + Shift + P

        //}

        //public void CallButtonFromAnotherRibbon()
        //{
        //    try
        //    {
        //        SendKeys.Send("%");
        //        SendKeys.Send("Y");
        //        SendKeys.Send("2");
        //        SendKeys.Send("%");
        //        SendKeys.Send("Y");
        //        SendKeys.Send("7");
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.ToString(), "Unexpected Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //    }
        //}
        private void ThisAddIn_Shutdown(object sender, System.EventArgs e)
        {
            //disable keyboard intercepts
            //KeyboardHooking.ReleaseHook();
        }

        #region VSTO generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(ThisAddIn_Startup);
            this.Shutdown += new System.EventHandler(ThisAddIn_Shutdown);
        }
        
        #endregion
    }
}
