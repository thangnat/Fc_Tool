using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Data.OleDb;
using System.IO;
//using IronXL;
using System.Runtime.InteropServices;
using Excel = Microsoft.Office.Interop.Excel;

namespace EXCEL_ADDINS
{
    public partial class UTaskPane : UserControl
    {
        //public static bool priority = true;
        public static DataTable _dt_filename = null;
        //public static string Seledcted_status_row_wf = string.Empty;

        public UTaskPane()
        {
            InitializeComponent();
            Get_Workbook_info();
            Forecast_information();
            rShowAllWF.Checked = true;
            create_tooltip();
            Connection_SQL._Applicationpath = cls_function.path_folder("BPvsDP");
        }

        void create_tooltip()
        {
            // Create the ToolTip and associate with the Form container.
            ToolTip toolTip1 = new ToolTip();

            // Set up the delays for the ToolTip.
            toolTip1.AutoPopDelay = 5000;
            toolTip1.InitialDelay = 1000;
            toolTip1.ReshowDelay = 500;
            // Force the ToolTip text to be displayed whether or not the form is active.
            toolTip1.ShowAlways = true;

            // Set up the ToolTip text for the Button and Checkbox.
            toolTip1.SetToolTip(this.CmdGenWFFirst, "Tạo Mới WF lần đầu tiên");
            toolTip1.SetToolTip(this.cmdRe_Gen_WF_Unit, "Thay đổi data WF theo từng module: Historical,\n Forecast,Forecast M-1, Budget, Pre-Budget, Trend...");
            toolTip1.SetToolTip(this.CmdAlert, "Bảng thông báo sau khi chạy tiến trình [tạo mới WF], \n  những lỗi gì xảy ra...");
            toolTip1.SetToolTip(this.cmdFilter, "Cho phép chọn hiển thị những vùng nào cần xem \n và những vùng nào cần ẩn đi(Historical, Forecast,forecast m-1,...");
            toolTip1.SetToolTip(this.cmdCreateWF_His, "Tạo Bảng [M-1] \n (cũng là bảng Forecast final của current month)");
            toolTip1.SetToolTip(this.cmdReviewBI, "Mở file BI \n (Dữ liệu trên file này link đến WF)");
            toolTip1.SetToolTip(this.CmdExportFM, "Kết hợp dữ liệu WF vs Spectrum master \n -->Xuất ra template Excel File để đẩy lên FM");
            toolTip1.SetToolTip(this.cmdGapBP, "Cho phép Compare số giữa \n BP vs Forecast DP");
            toolTip1.SetToolTip(this.rShowAllWF, "Hiển thị toàn bộ WF \n (bỏ filter toàn bộ)");
            toolTip1.SetToolTip(this.rShowTotalWFOnly, "Chỉ hiển thị Total line");
            toolTip1.SetToolTip(this.rShowBPvsFCLine, "Chỉ hiển thị BP vs FC \n line (6,7,8,9)");
            toolTip1.SetToolTip(this.cmdShowRibbon, "Cho phép ẩn hiện Ribbon trên Excel \n (nếu đang hide thì nhấn sẽ mở và ngược lại)");
            toolTip1.SetToolTip(this.ChkShowFormularbar, "Cho phép ẩn hiện Thanh công thức \n (Stick chọn là mở ngược lại là tắt)");
            //toolTip1.SetToolTip(this.checkBox1, "My checkBox1");
        }
        public void Get_Workbook_info()
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                Connection_SQL._fmkey = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B4"].Text;
                Connection_SQL._division = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B8"].Text;
                Connection_SQL._userID = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B15"].Text;
                Connection_SQL._path = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B17"].Text;
                Connection_SQL._fullname = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B16"].Text;
                //Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B43"].Text="123";
                Microsoft.Office.Interop.Excel.Worksheet sys_config = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.Worksheets["SysConfig"];
                sys_config.Range["B43"].Value2 = Connection_SQL._version_exe;
                Connection_SQL._server_name = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B46"].Text;
                Connection_SQL._Database_name = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["SysConfig"].Application.Range["B45"].Text;
                //Program.gsServerName = Connection_SQL._server_name;
                //Program.gsDatabaseName = Connection_SQL._Database_name;
            }
            else
            {
                Connection_SQL._fmkey = "";
                Connection_SQL._division = "";
                Connection_SQL._userID = "";
                Connection_SQL._path = "";
                Connection_SQL._fullname = "";

                Connection_SQL._server_name = "";
                Connection_SQL._Database_name = "";
                //Program.gsServerName = "";
                //Program.gsDatabaseName = "";
            }
            if (Connection_SQL._division.Length == 3)
            {
                _dt_filename = new DataTable();
                _dt_filename = Connection_SQL.GetDataTable(@"select FileName,FMKEY_NEW from V_FC_CONFIG_TOOL_NAME where Division = '" + Connection_SQL._division + "'");
                if (_dt_filename.Rows.Count == 0 || _dt_filename == null)
                {
                    Connection_SQL._FC_Filename = "";
                }
                else
                {
                    Connection_SQL._FC_Filename = _dt_filename.Rows[0]["FileName"].ToString() + ".xlsm";
                }
            }
            else
            {
                Connection_SQL._FC_Filename = "";
                Connection_SQL._path = "";
                Connection_SQL._userID = "";
                Connection_SQL._fullname = "";
            }
            //Ribbon1.SetConnectionAll();
        }
        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
        {
            if (keyData == (Keys.Control | Keys.B))
            {
                MessageBox.Show("Do Something");
                return true;
            }
            return base.ProcessCmdKey(ref msg, keyData);
        }
        #region nháp
        //void get_file_txt()
        //{
        //    //get text file config
        //    //var data = File
        //    //.ReadAllLines(@"Extension\H2T.ini")
        //    //.Select(x => x.Split('='))
        //    //.Where(x => x.Length > 1)
        //    //.ToDictionary(x => x[0].Trim(), x => x[1]);
        //    //cls_sys.Computername = Environment.MachineName;
        //    //Connection_SQL._division = data["Division"];
        //}
        #endregion
        private void UTaskPane_Load(object sender, EventArgs e)
        {
            //Forecast_information();
            if (Connection_SQL._division == "CPD" || Connection_SQL._division == "LDB")
            {
                cmdGapBP.Visible = true;
                rShowBPvsFCLine.Visible = true;
            }
            else
            {
                cmdGapBP.Visible = false;
                rShowBPvsFCLine.Visible = false;
            }
        }
        public void Forecast_information()
        {
            //hiện lên UI
            txtDivision.Text = Connection_SQL._division;
            txtFMKEY.Text = Connection_SQL._fmkey.Substring(0, 4) + "-" + Connection_SQL._fmkey.Substring(4, 2);
        }
        void Open_Adjust_Form()
        {

        }
        private void CmdExportFM_Click(object sender, EventArgs e)
        {
            //MessageBox.Show("under maintenance.../","[Loreal VN]",MessageBoxButtons.OK,MessageBoxIcon.Exclamation);

            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (Connection_SQL._division.Length < 3 || Connection_SQL._fmkey.Length < 6)
                {
                    MessageBox.Show("No data to Open form(" + Connection_SQL._division + "-" + Connection_SQL._fmkey + ")");
                    return;
                }
                else
                {
                    if (cls_function.Check_user_action())
                    {
                        //MessageBox.Show(Connection_SQL._division+"-"+Connection_SQL._fmkey);
                        FrmExportFMFull frm = new FrmExportFMFull(Cursor.Position.X, Cursor.Position.Y);// txtDivision.Text, txtFMKEY.Text.Replace("-", ""));
                        frm.StartPosition = FormStartPosition.CenterScreen;
                        frm.ShowDialog();
                    }
                    else
                    {
                        MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    }
                }
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
        private void CmdAdjustBom_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                Connection_SQL._subgrp = Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Worksheets["WF"].Application.Range["LE1"].Text;
                if (Connection_SQL._division.Length == 3 || Connection_SQL._fmkey.Replace("-", "").Length == 6)
                {
                    FrmAdjustBomHeader frm = new FrmAdjustBomHeader();
                    frm.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
                    frm.Height = 932;
                    frm.Width = 1859;
                    frm.ShowDialog();
                }
                else
                {
                    MessageBox.Show("Connection error.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdFilter_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                //Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("show_Filter2");

                FrmFilter frm = new FrmFilter(Cursor.Position.X, Cursor.Position.Y);
                frm.ShowDialog();
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
        //bool Check_user_action()
        //{
        //    bool _action = false;
        //    DataTable dt_user_info = new DataTable();
        //    //MessageBox.Show(Connection_SQL._userID);
        //    dt_user_info = Connection_SQL.GetDataTable(@"select [Action] from V_FC_CONFIG_USER_ALLOW where Division='"+Connection_SQL._division+"' and active = 1 and userid = '" + Connection_SQL._userID + "'");
        //    if (dt_user_info.Rows.Count == 0)
        //    {
        //        //MessageBox.Show("User name: " + Connection_SQL._userID + " invalid");
        //        _action = false;
        //    }
        //    else
        //    {
        //        string _action_status = "";
        //        _action_status = dt_user_info.Rows[0]["Action"].ToString();
        //        if (_action_status == "0")
        //        {
        //            _action = false;
        //        }
        //        else
        //        {
        //            _action = true;
        //        }
        //    }
        //    return _action;
        //}
        private void CmdGenWFFirst_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (cls_function.Check_user_action())
                {
                    FrmRe_GenPartial_WF frm = new FrmRe_GenPartial_WF(Cursor.Position.X, Cursor.Position.Y);// Connection_SQL._division, Connection_SQL._fmkey);
                    frm.StartPosition = FormStartPosition.CenterScreen;
                    frm.ShowDialog();
                }
                else
                {
                    MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdRefreshWF_Click(object sender, EventArgs e)
        {
            LbProcessing.Text = "Processing....";
            if (cls_function.Check_user_action())
            {
                string _type_refresh_ = "fc";
                SqlTransaction transaction = null;
                try
                {
                    // Open connection and begin transaction
                    Connection_SQL.KetnoiCSDL_SQL();
                    if (Connection_SQL.cnn.State == ConnectionState.Closed)
                    {
                        Connection_SQL.cnn.Open();
                    }
                    transaction = Connection_SQL.cnn.BeginTransaction();

                    // Acquire application lock to prevent concurrent execution
                    string lockResourceName = "WF_REFRESH_LOCK_" + Connection_SQL._division + "_" + Connection_SQL._fmkey;
                    int lockResult = AcquireAppLock(transaction, lockResourceName, 30000); // Wait up to 30 seconds

                    if (lockResult < 0)
                    {
                        // Lock acquisition failed
                        string lockMessage = GetLockResultMessage(lockResult);
                        MessageBox.Show(lockMessage, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        transaction?.Rollback();
                        transaction = null;
                        return;
                    }

                    bool result = true;
                    if (Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].ActiveSheet.name == "WF")
                    {
                        result = cls_function.Import_ExcelFile_New();
                        if (result)
                        {
                            //1. tính toán lại total & O+O & BP Gap % + Unit with FC
                            New_sp nw = new New_sp();
                            nw.sp_tag_update_wf_calculation_fc_unit_Refresh_All
                            (
                                Connection_SQL._division,
                                Connection_SQL._fmkey,
                                Connection_SQL._Seledcted_status_row_wf,
                                "fc"//type_refresh_.ToUpper()
                            );
                            if (nw.b_success == "1")
                            {
                                // Commit transaction before UI refresh
                                if (transaction != null)
                                {
                                    transaction.Commit();
                                    transaction = null;
                                }

                                if (_type_refresh_.ToUpper() == "ALL")
                                {
                                    //refresh ALl wf
                                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
                                }
                                else
                                {
                                    //refresh fc column only
                                    cls_function.refresh_WF_Question(false);
                                }
                            }
                            else
                            {
                                result = false;
                                // Rollback on stored procedure failure
                                if (transaction != null)
                                {
                                    transaction.Rollback();
                                    transaction = null;
                                }
                                MessageBox.Show(nw.c_errmsg, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            }
                        }
                        else
                        {
                            // Rollback on import failure
                            if (transaction != null)
                            {
                                transaction.Rollback();
                                transaction = null;
                            }
                            MessageBox.Show("Import tmp data fail[EXCEL --> Access --> SQL](" + cls_function._error_message + ")", "[L'Oreal VN]",
                                MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                    else if (Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].ActiveSheet.name == "Bom Header Forecast")
                    {
                        result = cls_function.Import_ExcelFile_BOM();
                        if (result)
                        {
                            //1. tính toán lại total & O+O & BP Gap % + Unit with FC
                            New_sp nw = new New_sp();
                            nw.sp_Update_Bom_Header_New2
                            (
                                Connection_SQL._division,
                                Connection_SQL._fmkey
                            );
                            if (nw.b_success == "1")
                            {
                                // Commit transaction on success
                                if (transaction != null)
                                {
                                    transaction.Commit();
                                    transaction = null;
                                }
                                MessageBox.Show("Save successfully.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            }
                            else
                            {
                                result = false;
                                // Rollback on stored procedure failure
                                if (transaction != null)
                                {
                                    transaction.Rollback();
                                    transaction = null;
                                }
                                MessageBox.Show(nw.c_errmsg, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            }
                        }
                        else
                        {
                            // Rollback on import failure
                            if (transaction != null)
                            {
                                transaction.Rollback();
                                transaction = null;
                            }
                            MessageBox.Show("Import BOM tmp data fail[EXCEL --> Access --> SQL](" + cls_function._error_message + ")", "[L'Oreal VN]",
                                MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                    else
                    {
                        // Commit transaction if no specific sheet processing
                        if (transaction != null)
                        {
                            transaction.Commit();
                            transaction = null;
                        }
                    }
                }
                catch (Exception ex)
                {
                    // Rollback transaction on any exception
                    if (transaction != null)
                    {
                        try
                        {
                            transaction.Rollback();
                        }
                        catch (Exception rollbackEx)
                        {
                            MessageBox.Show("Rollback error: " + rollbackEx.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                        transaction = null;
                    }
                    MessageBox.Show(ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
                finally
                {
                    // Ensure transaction is disposed and connection is closed
                    if (transaction != null)
                    {
                        transaction.Dispose();
                    }
                    if (Connection_SQL.cnn != null && Connection_SQL.cnn.State == ConnectionState.Open)
                    {
                        Connection_SQL.cnn.Close();
                    }
                }

                rShowAllWF.Checked = false;
            }
            else
            {
                MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            LbProcessing.Text = "...";
        }

        private void cmd_Gen_WF_Value_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_by_Type_view_Value");
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdCreateWF_His_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (cls_function.Check_user_action())
                {
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_by_Type_view_CREATE_WF_HIS");
                }
                else
                {
                    MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdReviewBI_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("OpenBI");
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdRe_Gen_WF_Unit_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                FrmRe_GenPartial_WF frm = new FrmRe_GenPartial_WF(Cursor.Position.X, Cursor.Position.Y);// txtDivision.Text,txtFMKEY.Text.Replace("-",""));
                frm.StartPosition = FormStartPosition.CenterScreen;
                frm.ShowDialog();
            }
            else
            {
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdShowRibbon_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("ShowRibbon");
            }
            //else
            //{
            //    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("ShowRibbon");
            //}
            //Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("ShowRibbon");
        }

        private void cmdSave_Click(object sender, EventArgs e)
        {


        }
        private bool Save_FC()
        {
            bool _result = false;
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                bool result = false;
                result = cls_function.Import_ExcelFile(Connection_SQL._division, Connection_SQL._FC_Filename, "FC_WF", "WF", "xlsm");
                if (result)
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_update_wf_fc_adjust_unit
                    (
                        Connection_SQL._division,
                        Connection_SQL._fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        _result = true;
                    }
                    else
                    {
                        _result = false;
                    }
                }
                else
                {
                    _result = false;
                }
            }
            else
            {
                _result = false;
            }
            return _result;
        }

        private void cmdTotalWF_Click(object sender, EventArgs e)
        {

        }
        private void UTaskPane_KeyPress(object sender, KeyPressEventArgs e)
        {
            //if (e.KeyChar == Convert.ToChar(Keys.F1))
            //{
            //    MessageBox.Show("test shortcut key.../");
            //}
        }

        private void cmdFilter_PreviewKeyDown(object sender, PreviewKeyDownEventArgs e)
        {

        }

        private void UTaskPane_PreviewKeyDown(object sender, PreviewKeyDownEventArgs e)
        {
            //if (e.KeyCode == Keys.Control && e.KeyCode == Keys.Shift && e.KeyCode == Keys.S)
            //{
            //    MessageBox.Show("test shortcut key.../");
            //}
        }

        private void UTaskPane_KeyUp(object sender, KeyEventArgs e)
        {

        }
        public void UTaskPane_KeyDown(object sender, KeyEventArgs e)
        {
            //if (e.KeyCode == Keys.Control && e.KeyCode == Keys.Shift && e.KeyCode == Keys.S)
            //{
            //    MessageBox.Show("test shortcut key.../");
            //}
        }


        private void button2_Click(object sender, EventArgs e)
        {

        }
        private void ChkCompareGapBP_CheckStateChanged(object sender, EventArgs e)
        {
            //if (ChkCompareGapBP.Checked)
            //{
            //    chk_BP_Unit.Visible = true;
            //    Chk_BP_Percent.Visible = true;
            //}
            //else
            //{
            //    chk_BP_Unit.Visible = false;
            //    Chk_BP_Percent.Visible = false;
            //}
        }

        private void cmdGapBP_Click(object sender, EventArgs e)
        {
            //string _path_folder=Application.StartupPath;
            //MessageBox.Show(Connection_SQL._Applicationpath);
            string _full_path = Connection_SQL._Applicationpath + "WinFormsApp2.exe";
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                //if (Check_user_action())
                //{

                //}
                //else
                //{
                //    MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                //}
                if (Connection_SQL._Applicationpath.Length > 0)
                {
                    if (Process.GetProcessesByName("WinFormsApp2").Length > 0)
                    {
                        if (SingleInstance.AlreadyRunning())
                        {
                            //System.Windows.Application.Current.Shutdown(0);
                        }
                    }
                    else
                    {
                        string list_argument = "D:" + Connection_SQL._division + ",F:" + Connection_SQL._fmkey + ",U:" + Connection_SQL._userID + ",L:Compare"
                            + ",S:" + Connection_SQL._server_name + ",A:" + Connection_SQL._Database_name;
                        //string list_argument = "D:" + Connection_SQL._division + ",F:" + Connection_SQL._fmkey + ",U:" + Connection_SQL._userID + ",L:TEST";
                        //MessageBox.Show(list_argument);
                        //MessageBox.Show(list_argument+"\n"+ _full_path);
                        Process.Start(_full_path, list_argument);
                    }
                }
                else
                {
                    MessageBox.Show("Application path not contains.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }

        private void rShowAllWF_CheckedChanged(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (rShowAllWF.Checked)
                {
                    //unfilter
                    Microsoft.Office.Interop.Excel.Worksheet ws_wf = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.Worksheets["WF"];
                    ws_wf.Activate();
                    Connection_SQL._Seledcted_status_row_wf = "Show_All_Selected";
                    //cls_function.refresh_WF_Question(false);
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("unfilter");
                    //Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_by_Type_view_Unit");
                    //cls_function.refresh_WF_Question(false);
                }
            }
        }

        private void rShowTotalWFOnly_CheckedChanged(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (rShowTotalWFOnly.Checked)
                {
                    //unfilter
                    Microsoft.Office.Interop.Excel.Worksheet ws_wf = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.Worksheets["WF"];
                    ws_wf.Activate();
                    Connection_SQL._Seledcted_status_row_wf = "Show_Total_Selected";
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Show_wf_Total_Only");
                }
            }
        }

        private void rShowBPvsFCLine_CheckedChanged(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (rShowBPvsFCLine.Checked)
                {
                    //unfilter
                    Microsoft.Office.Interop.Excel.Worksheet ws_wf = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.Worksheets["WF"];
                    ws_wf.Activate();
                    Connection_SQL._Seledcted_status_row_wf = "Show_BP_Selected";
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("show_FC_vs_BP_Line");
                }
            }
        }

        private void ChkShowFormularbar_CheckedChanged(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (ChkShowFormularbar.Checked)
                {
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Hide_formular_bar");
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("show_formular_bar");
                }
                else
                {
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("show_formular_bar");
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Hide_formular_bar");
                }
            }
        }

        private void CmdAlert_Click(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                FrmAlert frm = new FrmAlert(Cursor.Position.X, Cursor.Position.Y);
                frm.StartPosition = FormStartPosition.CenterScreen;
                frm.ShowDialog();
            }
            //FrmTEST frm = new FrmTEST();
            //frm.StartPosition = FormStartPosition.CenterScreen;
            //frm.ShowDialog();
        }
        //Hover----------------------------------------------------------------------------
        private void CmdGenWFFirst_MouseEnter(object sender, EventArgs e)
        {
            CmdGenWFFirst.BackColor = Color.Green;
        }
        private void CmdGenWFFirst_MouseLeave(object sender, EventArgs e)
        {
            CmdGenWFFirst.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void cmdRe_Gen_WF_Unit_MouseEnter(object sender, EventArgs e)
        {
            cmdRe_Gen_WF_Unit.BackColor = Color.Green;
        }
        private void cmdRe_Gen_WF_Unit_MouseLeave(object sender, EventArgs e)
        {
            cmdRe_Gen_WF_Unit.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------                
        private void CmdAlert_MouseEnter(object sender, EventArgs e)
        {
            CmdAlert.BackColor = Color.Green;
        }
        private void CmdAlert_MouseLeave(object sender, EventArgs e)
        {
            CmdAlert.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void cmdFilter_MouseEnter(object sender, EventArgs e)
        {
            cmdFilter.BackColor = Color.Green;
        }
        private void cmdFilter_MouseLeave(object sender, EventArgs e)
        {
            cmdFilter.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void cmdCreateWF_His_MouseEnter(object sender, EventArgs e)
        {
            cmdCreateWF_His.BackColor = Color.Green;
        }
        private void cmdCreateWF_His_MouseLeave(object sender, EventArgs e)
        {
            cmdCreateWF_His.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void cmdReviewBI_MouseEnter(object sender, EventArgs e)
        {
            cmdReviewBI.BackColor = Color.Green;
        }
        private void cmdReviewBI_MouseLeave(object sender, EventArgs e)
        {
            cmdReviewBI.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void CmdExportFM_MouseEnter(object sender, EventArgs e)
        {
            CmdExportFM.BackColor = Color.Green;
        }
        private void CmdExportFM_MouseLeave(object sender, EventArgs e)
        {
            CmdExportFM.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void cmdGapBP_MouseEnter(object sender, EventArgs e)
        {
            cmdGapBP.BackColor = Color.Green;
        }
        private void cmdGapBP_MouseLeave(object sender, EventArgs e)
        {
            cmdGapBP.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void cmdShowRibbon_MouseEnter(object sender, EventArgs e)
        {
            cmdShowRibbon.BackColor = Color.Green;
        }
        private void cmdShowRibbon_MouseLeave(object sender, EventArgs e)
        {
            cmdShowRibbon.BackColor = Color.White;
        }
        //Hover----------------------------------------------------------------------------
        private void rShowAllWF_MouseEnter(object sender, EventArgs e)
        {
            rShowAllWF.BackColor = Color.Green;
        }

        private void rShowAllWF_MouseLeave(object sender, EventArgs e)
        {
            rShowAllWF.BackColor = Color.MidnightBlue;
        }
        //Hover----------------------------------------------------------------------------
        private void rShowTotalWFOnly_MouseEnter(object sender, EventArgs e)
        {
            rShowTotalWFOnly.BackColor = Color.Green;
        }

        private void rShowTotalWFOnly_MouseLeave(object sender, EventArgs e)
        {
            rShowTotalWFOnly.BackColor = Color.MidnightBlue;
        }
        //Hover----------------------------------------------------------------------------
        private void rShowBPvsFCLine_MouseEnter(object sender, EventArgs e)
        {
            rShowBPvsFCLine.BackColor = Color.Green;
        }

        private void rShowBPvsFCLine_MouseLeave(object sender, EventArgs e)
        {
            rShowBPvsFCLine.BackColor = Color.MidnightBlue;
        }
        //Hover----------------------------------------------------------------------------
        private void ChkShowFormularbar_MouseEnter(object sender, EventArgs e)
        {
            ChkShowFormularbar.BackColor = Color.Green;
        }

        private void ChkShowFormularbar_MouseLeave(object sender, EventArgs e)
        {
            ChkShowFormularbar.BackColor = Color.MidnightBlue;
        }

        private void cmdTotalWF_Click_1(object sender, EventArgs e)
        {
            cls_function.refresh_WF_Question(false);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            //cls_function.Save_And_Refresh_FC();
        }

        private void cmdLogin_Click(object sender, EventArgs e)
        {

        }

        private void timer2_Tick(object sender, EventArgs e)
        {

        }
        static bool IsOpened(string wbook)
        {
            bool isOpened = true;
            Excel.Application exApp;
            exApp = (Excel.Application)System.Runtime.InteropServices.Marshal.GetActiveObject("Excel.Application");
            try
            {
                exApp.Workbooks.get_Item(wbook);
            }
            catch (Exception)
            {
                isOpened = false;
            }
            return isOpened;
        }

        private void cmdLoseExcel_Click(object sender, EventArgs e)
        {
            ////Microsoft.Office.Interop.Excel.Application = new Microsoft.Office.Interop.Excel.Application();
            //Microsoft.Office.Interop.Excel.Application application = new Microsoft.Office.Interop.Excel.Application();
            ////application.Visible = true;
            //Microsoft.Office.Interop.Excel.Workbook workbook = application.Workbooks.Close(@"C:\phuongho\PROJECT\DOCUMENT\DP\Forecast_Tool\FC_BI_User_CPD.xlsm");
            //workbook.Close();
        }

        private void cmdRefreshWF_Enter(object sender, EventArgs e)
        {
            //grpProcessing.Visible = true;
            //System.Threading.Thread.Sleep(3000);
            LbProcessing.Text = "Processing....";
        }

        private void rshowFcline_CheckedChanged(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
            {
                if (rshowFcline.Checked)
                {
                    //unfilter
                    Microsoft.Office.Interop.Excel.Worksheet ws_wf = (Microsoft.Office.Interop.Excel.Worksheet)Globals.ThisAddIn.Application.Worksheets["WF"];
                    ws_wf.Activate();
                    Connection_SQL._Seledcted_status_row_wf = "Show_All_Selected";
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("show_FC_Line");
                }
            }
        }

        private void rshowFcline_MouseEnter(object sender, EventArgs e)
        {
            rshowFcline.BackColor = Color.Green;
        }

        private void rshowFcline_MouseLeave(object sender, EventArgs e)
        {
            rshowFcline.BackColor = Color.MidnightBlue;
        }

        private void cmdRelogin_Click(object sender, EventArgs e)
        {
            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Re_login");
        }

        #region Application Lock Helper Methods

        /// <summary>
        /// Acquires an application lock using sp_getapplock
        /// </summary>
        /// <param name="transaction">The SQL transaction to associate with the lock</param>
        /// <param name="resourceName">The name of the lock resource</param>
        /// <param name="timeoutMs">Timeout in milliseconds (default 30000 = 30 seconds)</param>
        /// <returns>Lock result code: >= 0 success, < 0 failure</returns>
        private int AcquireAppLock(SqlTransaction transaction, string resourceName, int timeoutMs = 30000)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("sp_getapplock", Connection_SQL.cnn, transaction))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 0;

                    // Add parameters for sp_getapplock
                    cmd.Parameters.Add(new SqlParameter("@Resource", SqlDbType.NVarChar, 255)).Value = resourceName;
                    cmd.Parameters.Add(new SqlParameter("@LockMode", SqlDbType.NVarChar, 32)).Value = "Exclusive";
                    cmd.Parameters.Add(new SqlParameter("@LockOwner", SqlDbType.NVarChar, 32)).Value = "Transaction";
                    cmd.Parameters.Add(new SqlParameter("@LockTimeout", SqlDbType.Int)).Value = timeoutMs;

                    // Add return value parameter
                    SqlParameter returnValue = new SqlParameter("@ReturnValue", SqlDbType.Int);
                    returnValue.Direction = ParameterDirection.ReturnValue;
                    cmd.Parameters.Add(returnValue);

                    // Execute
                    cmd.ExecuteNonQuery();

                    // Get return value
                    int result = (int)returnValue.Value;
                    return result;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error acquiring lock: " + ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return -999; // Custom error code
            }
        }

        /// <summary>
        /// Releases an application lock using sp_releaseapplock
        /// </summary>
        /// <param name="transaction">The SQL transaction associated with the lock</param>
        /// <param name="resourceName">The name of the lock resource</param>
        /// <returns>0 on success, -1 on failure</returns>
        private int ReleaseAppLock(SqlTransaction transaction, string resourceName)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("sp_releaseapplock", Connection_SQL.cnn, transaction))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 0;

                    // Add parameters for sp_releaseapplock
                    cmd.Parameters.Add(new SqlParameter("@Resource", SqlDbType.NVarChar, 255)).Value = resourceName;
                    cmd.Parameters.Add(new SqlParameter("@LockOwner", SqlDbType.NVarChar, 32)).Value = "Transaction";

                    // Add return value parameter
                    SqlParameter returnValue = new SqlParameter("@ReturnValue", SqlDbType.Int);
                    returnValue.Direction = ParameterDirection.ReturnValue;
                    cmd.Parameters.Add(returnValue);

                    // Execute
                    cmd.ExecuteNonQuery();

                    // Get return value
                    int result = (int)returnValue.Value;
                    return result;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error releasing lock: " + ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return -1;
            }
        }

        /// <summary>
        /// Gets a user-friendly message for sp_getapplock return codes
        /// </summary>
        /// <param name="returnCode">The return code from sp_getapplock</param>
        /// <returns>User-friendly error message</returns>
        private string GetLockResultMessage(int returnCode)
        {
            switch (returnCode)
            {
                case 0:
                    return "Lock granted successfully.";
                case 1:
                    return "Lock granted successfully after waiting for other incompatible locks to be released.";
                case -1:
                    return "Lock request timed out. Another user is currently processing this data. Please try again later.";
                case -2:
                    return "Lock request was canceled.";
                case -3:
                    return "Lock request was chosen as a deadlock victim.";
                case -999:
                    return "Error occurred while trying to acquire lock. Please contact support.";
                default:
                    return "Unexpected lock result code: " + returnCode;
            }
        }

        #endregion
    }
}
