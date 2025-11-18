
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
        public void Ribbon1_Load(object sender, RibbonUIEventArgs e)
        {
            SetConnectionAll();
        }
        
        public static void SetConnectionAll()//string sFormName, string sClassName, Form frm)
        {
            //-----------------------------------------------------------------
            Cls_BaseSys Cls_basesys = new Cls_BaseSys();
            Cls_basesys.PhanHanh = Program.gnPhanHanh;
            Cls_basesys.Right = Program.gsRight;
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
            Cls_basesys.ConnectionString = Program.gsConnectionString_admin;
        }

        private void cmd_Import_Historical_Data_Click(object sender, RibbonControlEventArgs e)
        {
            
        }
        private void CmdTaskPane_Click(object sender, RibbonControlEventArgs e)
        {
            ThisAddIn._myCustomTaskPane.Visible = true;
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name == Connection_SQL._FC_Filename)
            {
                ThisAddIn._myCustomTaskPane.Visible = true;
                Group_SystemConfig.Visible = true;
                Group_Version.Visible = true;
            }
            else
            {
                ThisAddIn._myCustomTaskPane.Visible =false;
                Group_SystemConfig.Visible = false;
                Group_Version.Visible = false;

                Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.DisplayFormulaBar=true;
            }
            
        }

        private void cmdInstallNewversion_Click(object sender, RibbonControlEventArgs e)
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
                
                if (!cls_function.Check_form_is_open("FrmUpdate_Version"))
                {
                    FrmUpdate_Version frm1 = new FrmUpdate_Version(dt_ver.Rows[0]["Content"].ToString());
                    frm1.StartPosition = FormStartPosition.CenterScreen;
                    frm1.ShowDialog();
                }
            }
            else
            {
                MessageBox.Show("Chưa có version mới","[Loreal VN]",MessageBoxButtons.OK,MessageBoxIcon.Information);
            }
        }

        private void timer2_Tick(object sender, EventArgs e)
        {
            //check_version();
        }

        
        private void cmd_ChangePassword_Click(object sender, RibbonControlEventArgs e)
        {
            Frm_ChangePassword frm = new Frm_ChangePassword();
            frm.StartPosition = FormStartPosition.CenterScreen;
            frm.ShowDialog();
        }

        private void cmdUpdateMasterWF_Click(object sender, RibbonControlEventArgs e)
        {
            if (cls_function.Check_user_action())
            {
                DialogResult drl = MessageBox.Show("Do you want to re-update master column on WF?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (drl == DialogResult.Yes)
                {
                    try
                    {
                        New_sp nw = new New_sp();
                        nw.sp_Update_WF_Master
                        (
                            Connection_SQL._division,
                            Connection_SQL._fmkey
                        );
                        //MessageBox.Show(nw.b_success);
                        if (nw.b_success == "1")
                        {
                            MessageBox.Show("Update successfully.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Information);
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
            else
            {
                MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdOpenExcel_Click(object sender, RibbonControlEventArgs e)
        {
            try
            {
                Process.Start(new ProcessStartInfo { FileName = Connection_SQL._WFpath + "FC_WORKING_FILE.xlsm", UseShellExecute = true });
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdImportSpectrum_Click(object sender, RibbonControlEventArgs e)
        {
            try
            {
                if (cls_function.Check_user_action())
                {
                    DialogResult drl = MessageBox.Show("Do you want to import new spectrum?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                    if (drl == DialogResult.Yes)
                    {
                        New_sp nw = new New_sp();
                        nw.sp_add_FC_Spectrum
                        (
                            Connection_SQL._division,
                            Connection_SQL._fmkey
                        );
                        if (nw.b_success == "1")
                        {
                            MessageBox.Show("Import Spectrum successfully.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Information);
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

        private void cmdSOFC_Click(object sender, RibbonControlEventArgs e)
        {
            if (cls_function.Check_user_action())
            {
                string _full_path = Connection_SQL._Applicationpath + "WinFormsApp2.exe";
                if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._default_Workbook_name) >= 0)
                {
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
                            string list_argument = "D:" + Connection_SQL._division + ",F:" + Connection_SQL._fmkey + ",U:" + Connection_SQL._userID + ",L:REPORT,S:" + Connection_SQL._server_name + ",A:" + Connection_SQL._Database_name;
                            Process.Start(_full_path, list_argument);
                        }
                    }
                    else
                    {
                        MessageBox.Show("Application path not contains.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    }
                }
            }
            else
            {
                MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdAdd_newFC_Click(object sender, RibbonControlEventArgs e)
        {
            if (cls_function.Check_user_action())
            {
                Frm_Add_New frm = new Frm_Add_New();
                frm.ShowDialog();
            }
            else
            {
                MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdSellout_historical_Click(object sender, RibbonControlEventArgs e)
        {
            if (cls_function.Check_user_action())
            {
                DialogResult drl = MessageBox.Show("Do you want to Import SISOSIT DATA?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (drl == DialogResult.Yes)
                {
                    frm_PeriodKey frm = new frm_PeriodKey();
                    frm.StartPosition = FormStartPosition.CenterScreen;
                    frm.ShowDialog();
                }
            }
            else
            {
                MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void cmdRisk_Click(object sender, RibbonControlEventArgs e)
        {
            try
            {
                DialogResult drl = MessageBox.Show("Do you want to check Risk DATA?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (drl == DialogResult.Yes)
                {
                    New_sp nw = new New_sp();
                    nw.sp_fc_fm_risk_3M
                    (
                        Connection_SQL._division,
                        Connection_SQL._fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        MessageBox.Show("Run check Risk Data successfully.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Information);
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

        private void cmdSlob_Click(object sender, RibbonControlEventArgs e)
        {
            try
            {
                DialogResult drl = MessageBox.Show("Do you want to check Slob DATA?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (drl == DialogResult.Yes)
                {
                    New_sp nw = new New_sp();
                    nw.sp_tag_update_slob_wf
                    (
                        Connection_SQL._division,
                        Connection_SQL._fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        MessageBox.Show("Run check Slob Data successfully.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Information);
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

        private void cmd_GapBP_Click(object sender, RibbonControlEventArgs e)
        {
            try
            {
                DialogResult drl = MessageBox.Show("Do you want to check GAP BP DATA?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                if (drl == DialogResult.Yes)
                {
                    New_sp nw = new New_sp();
                    nw.sp_Check_GAP_NEW
                    (
                        Connection_SQL._division,
                        Connection_SQL._fmkey
                    );
                    if (nw.b_success == "1")
                    {
                        MessageBox.Show("Run check GAP BP Data successfully.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Information);
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

        private void button1_Click(object sender, RibbonControlEventArgs e)
        {
            MessageBox.Show("server name:" + Connection_SQL._server_name+" database name: "+Connection_SQL._Database_name);
            MessageBox.Show("server name:" + Connection_SQL.Constr);
        }
    }
}
