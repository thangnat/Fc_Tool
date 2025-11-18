
namespace EXCEL_ADDINS
{
    partial class Ribbon1 : Microsoft.Office.Tools.Ribbon.RibbonBase
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        public Ribbon1()
            : base(Globals.Factory.GetRibbonFactory())
        {
            InitializeComponent();
        }

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.Tab_ForecastTool = this.Factory.CreateRibbonTab();
            this.Group_SystemConfig = this.Factory.CreateRibbonGroup();
            this.CmdTaskPane = this.Factory.CreateRibbonButton();
            this.cmd_ChangePassword = this.Factory.CreateRibbonButton();
            this.Group_Version = this.Factory.CreateRibbonGroup();
            this.cmdInstallNewversion = this.Factory.CreateRibbonButton();
            this.cmdOpenExcel = this.Factory.CreateRibbonButton();
            this.group1 = this.Factory.CreateRibbonGroup();
            this.cmdSellout_historical = this.Factory.CreateRibbonButton();
            this.cmdImportSpectrum = this.Factory.CreateRibbonButton();
            this.cmdAdd_newFC = this.Factory.CreateRibbonButton();
            this.group2 = this.Factory.CreateRibbonGroup();
            this.cmdSOFC = this.Factory.CreateRibbonButton();
            this.button1 = this.Factory.CreateRibbonButton();
            this.group3 = this.Factory.CreateRibbonGroup();
            this.cmdUpdateMasterWF = this.Factory.CreateRibbonButton();
            this.cmdRisk = this.Factory.CreateRibbonButton();
            this.cmdSlob = this.Factory.CreateRibbonButton();
            this.cmd_GapBP = this.Factory.CreateRibbonButton();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.timer2 = new System.Windows.Forms.Timer(this.components);
            this.Tab_ForecastTool.SuspendLayout();
            this.Group_SystemConfig.SuspendLayout();
            this.Group_Version.SuspendLayout();
            this.group1.SuspendLayout();
            this.group2.SuspendLayout();
            this.group3.SuspendLayout();
            this.SuspendLayout();
            // 
            // Tab_ForecastTool
            // 
            this.Tab_ForecastTool.ControlId.ControlIdType = Microsoft.Office.Tools.Ribbon.RibbonControlIdType.Office;
            this.Tab_ForecastTool.Groups.Add(this.Group_SystemConfig);
            this.Tab_ForecastTool.Groups.Add(this.Group_Version);
            this.Tab_ForecastTool.Groups.Add(this.group1);
            this.Tab_ForecastTool.Groups.Add(this.group2);
            this.Tab_ForecastTool.Groups.Add(this.group3);
            this.Tab_ForecastTool.Label = "Forecast Tool";
            this.Tab_ForecastTool.Name = "Tab_ForecastTool";
            // 
            // Group_SystemConfig
            // 
            this.Group_SystemConfig.Items.Add(this.CmdTaskPane);
            this.Group_SystemConfig.Items.Add(this.cmd_ChangePassword);
            this.Group_SystemConfig.Label = "System Config";
            this.Group_SystemConfig.Name = "Group_SystemConfig";
            // 
            // CmdTaskPane
            // 
            this.CmdTaskPane.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.CmdTaskPane.Image = global::EXCEL_ADDINS.Properties.Resources.tasks48x48;
            this.CmdTaskPane.Label = "Task Pane";
            this.CmdTaskPane.Name = "CmdTaskPane";
            this.CmdTaskPane.ShowImage = true;
            this.CmdTaskPane.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.CmdTaskPane_Click);
            // 
            // cmd_ChangePassword
            // 
            this.cmd_ChangePassword.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmd_ChangePassword.Image = global::EXCEL_ADDINS.Properties.Resources.lock_padlock_password_security48x48;
            this.cmd_ChangePassword.Label = "Change Password";
            this.cmd_ChangePassword.Name = "cmd_ChangePassword";
            this.cmd_ChangePassword.ShowImage = true;
            this.cmd_ChangePassword.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmd_ChangePassword_Click);
            // 
            // Group_Version
            // 
            this.Group_Version.Items.Add(this.cmdInstallNewversion);
            this.Group_Version.Items.Add(this.cmdOpenExcel);
            this.Group_Version.Label = "Update Version";
            this.Group_Version.Name = "Group_Version";
            // 
            // cmdInstallNewversion
            // 
            this.cmdInstallNewversion.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdInstallNewversion.Image = global::EXCEL_ADDINS.Properties.Resources.Install_64x64;
            this.cmdInstallNewversion.Label = "Install New version";
            this.cmdInstallNewversion.Name = "cmdInstallNewversion";
            this.cmdInstallNewversion.ShowImage = true;
            this.cmdInstallNewversion.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdInstallNewversion_Click);
            // 
            // cmdOpenExcel
            // 
            this.cmdOpenExcel.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdOpenExcel.Image = global::EXCEL_ADDINS.Properties.Resources.excel_64x64;
            this.cmdOpenExcel.Label = "Open WF";
            this.cmdOpenExcel.Name = "cmdOpenExcel";
            this.cmdOpenExcel.ShowImage = true;
            this.cmdOpenExcel.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdOpenExcel_Click);
            // 
            // group1
            // 
            this.group1.Items.Add(this.cmdSellout_historical);
            this.group1.Items.Add(this.cmdImportSpectrum);
            this.group1.Items.Add(this.cmdAdd_newFC);
            this.group1.Label = "Accessories";
            this.group1.Name = "group1";
            // 
            // cmdSellout_historical
            // 
            this.cmdSellout_historical.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdSellout_historical.Image = global::EXCEL_ADDINS.Properties.Resources.SALE_64X64;
            this.cmdSellout_historical.Label = "SISOSIT HISTORICAL";
            this.cmdSellout_historical.Name = "cmdSellout_historical";
            this.cmdSellout_historical.ShowImage = true;
            this.cmdSellout_historical.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdSellout_historical_Click);
            // 
            // cmdImportSpectrum
            // 
            this.cmdImportSpectrum.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdImportSpectrum.Image = global::EXCEL_ADDINS.Properties.Resources.Create1;
            this.cmdImportSpectrum.Label = "Import Spectrum";
            this.cmdImportSpectrum.Name = "cmdImportSpectrum";
            this.cmdImportSpectrum.ShowImage = true;
            this.cmdImportSpectrum.Visible = false;
            this.cmdImportSpectrum.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdImportSpectrum_Click);
            // 
            // cmdAdd_newFC
            // 
            this.cmdAdd_newFC.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdAdd_newFC.Image = global::EXCEL_ADDINS.Properties.Resources.Add_new_rows_64x64;
            this.cmdAdd_newFC.Label = "Add New Line";
            this.cmdAdd_newFC.Name = "cmdAdd_newFC";
            this.cmdAdd_newFC.ShowImage = true;
            this.cmdAdd_newFC.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdAdd_newFC_Click);
            // 
            // group2
            // 
            this.group2.Items.Add(this.cmdSOFC);
            this.group2.Items.Add(this.button1);
            this.group2.Label = "Report";
            this.group2.Name = "group2";
            // 
            // cmdSOFC
            // 
            this.cmdSOFC.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdSOFC.Image = global::EXCEL_ADDINS.Properties.Resources.tasks48x48;
            this.cmdSOFC.Label = "Report forecast";
            this.cmdSOFC.Name = "cmdSOFC";
            this.cmdSOFC.ShowImage = true;
            this.cmdSOFC.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdSOFC_Click);
            // 
            // button1
            // 
            this.button1.Label = "button1";
            this.button1.Name = "button1";
            this.button1.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.button1_Click);
            // 
            // group3
            // 
            this.group3.Items.Add(this.cmdUpdateMasterWF);
            this.group3.Items.Add(this.cmdRisk);
            this.group3.Items.Add(this.cmdSlob);
            this.group3.Items.Add(this.cmd_GapBP);
            this.group3.Label = "Update";
            this.group3.Name = "group3";
            // 
            // cmdUpdateMasterWF
            // 
            this.cmdUpdateMasterWF.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdUpdateMasterWF.Image = global::EXCEL_ADDINS.Properties.Resources.Update64x64;
            this.cmdUpdateMasterWF.Label = "Update Master WF";
            this.cmdUpdateMasterWF.Name = "cmdUpdateMasterWF";
            this.cmdUpdateMasterWF.ShowImage = true;
            this.cmdUpdateMasterWF.Visible = false;
            this.cmdUpdateMasterWF.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdUpdateMasterWF_Click);
            // 
            // cmdRisk
            // 
            this.cmdRisk.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdRisk.Image = global::EXCEL_ADDINS.Properties.Resources.risk_64x64;
            this.cmdRisk.Label = "Update risk";
            this.cmdRisk.Name = "cmdRisk";
            this.cmdRisk.ShowImage = true;
            this.cmdRisk.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdRisk_Click);
            // 
            // cmdSlob
            // 
            this.cmdSlob.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmdSlob.Image = global::EXCEL_ADDINS.Properties.Resources.Slob_64x64;
            this.cmdSlob.Label = "Update Slob";
            this.cmdSlob.Name = "cmdSlob";
            this.cmdSlob.ShowImage = true;
            this.cmdSlob.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmdSlob_Click);
            // 
            // cmd_GapBP
            // 
            this.cmd_GapBP.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmd_GapBP.Image = global::EXCEL_ADDINS.Properties.Resources.check_gap_64x64;
            this.cmd_GapBP.Label = "GAP BP";
            this.cmd_GapBP.Name = "cmd_GapBP";
            this.cmd_GapBP.ShowImage = true;
            this.cmd_GapBP.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmd_GapBP_Click);
            // 
            // timer1
            // 
            this.timer1.Interval = 500;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // timer2
            // 
            this.timer2.Interval = 5000;
            this.timer2.Tick += new System.EventHandler(this.timer2_Tick);
            // 
            // Ribbon1
            // 
            this.Name = "Ribbon1";
            this.RibbonType = "Microsoft.Excel.Workbook";
            this.Tabs.Add(this.Tab_ForecastTool);
            this.Load += new Microsoft.Office.Tools.Ribbon.RibbonUIEventHandler(this.Ribbon1_Load);
            this.Tab_ForecastTool.ResumeLayout(false);
            this.Tab_ForecastTool.PerformLayout();
            this.Group_SystemConfig.ResumeLayout(false);
            this.Group_SystemConfig.PerformLayout();
            this.Group_Version.ResumeLayout(false);
            this.Group_Version.PerformLayout();
            this.group1.ResumeLayout(false);
            this.group1.PerformLayout();
            this.group2.ResumeLayout(false);
            this.group2.PerformLayout();
            this.group3.ResumeLayout(false);
            this.group3.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        internal Microsoft.Office.Tools.Ribbon.RibbonTab Tab_ForecastTool;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup Group_SystemConfig;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton CmdTaskPane;
        public System.Windows.Forms.Timer timer1;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup Group_Version;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdInstallNewversion;
        private System.Windows.Forms.Timer timer2;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmd_ChangePassword;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup group1;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdUpdateMasterWF;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup group2;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdSOFC;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdOpenExcel;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdImportSpectrum;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdAdd_newFC;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdSellout_historical;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup group3;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdRisk;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmdSlob;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton cmd_GapBP;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton button1;
    }

    partial class ThisRibbonCollection
    {
        internal Ribbon1 Ribbon1
        {
            get { return this.GetRibbon<Ribbon1>(); }
        }
    }
}
