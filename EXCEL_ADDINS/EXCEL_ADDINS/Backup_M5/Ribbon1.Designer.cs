
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
            this.tab1 = this.Factory.CreateRibbonTab();
            this.group2 = this.Factory.CreateRibbonGroup();
            this.CmdRefreshHostName = this.Factory.CreateRibbonButton();
            this.button1 = this.Factory.CreateRibbonButton();
            this.CmdOpenWF = this.Factory.CreateRibbonButton();
            this.CmdTaskPane = this.Factory.CreateRibbonButton();
            this.group1 = this.Factory.CreateRibbonGroup();
            this.cmd_Import_Historical_Data = this.Factory.CreateRibbonButton();
            this.Cmd_Import_Master_Data = this.Factory.CreateRibbonButton();
            this.tab1.SuspendLayout();
            this.group2.SuspendLayout();
            this.group1.SuspendLayout();
            this.SuspendLayout();
            // 
            // tab1
            // 
            this.tab1.ControlId.ControlIdType = Microsoft.Office.Tools.Ribbon.RibbonControlIdType.Office;
            this.tab1.Groups.Add(this.group2);
            this.tab1.Groups.Add(this.group1);
            this.tab1.Label = "Forecast Tool";
            this.tab1.Name = "tab1";
            // 
            // group2
            // 
            this.group2.Items.Add(this.CmdRefreshHostName);
            this.group2.Items.Add(this.button1);
            this.group2.Items.Add(this.CmdOpenWF);
            this.group2.Items.Add(this.CmdTaskPane);
            this.group2.Label = "System Config";
            this.group2.Name = "group2";
            // 
            // CmdRefreshHostName
            // 
            this.CmdRefreshHostName.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.CmdRefreshHostName.Image = global::EXCEL_ADDINS.Properties.Resources._317717_operating_system_windows_icon;
            this.CmdRefreshHostName.Label = "Refresh Host name";
            this.CmdRefreshHostName.Name = "CmdRefreshHostName";
            this.CmdRefreshHostName.ShowImage = true;
            this.CmdRefreshHostName.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.CmdRefreshHostName_Click);
            // 
            // button1
            // 
            this.button1.Label = "";
            this.button1.Name = "button1";
            // 
            // CmdOpenWF
            // 
            this.CmdOpenWF.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.CmdOpenWF.Image = global::EXCEL_ADDINS.Properties.Resources.Open_Excel48;
            this.CmdOpenWF.Label = "Open Working File";
            this.CmdOpenWF.Name = "CmdOpenWF";
            this.CmdOpenWF.ShowImage = true;
            this.CmdOpenWF.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.CmdOpenWF_Click);
            // 
            // CmdTaskPane
            // 
            this.CmdTaskPane.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.CmdTaskPane.Image = global::EXCEL_ADDINS.Properties.Resources.Task;
            this.CmdTaskPane.Label = "Task Pane";
            this.CmdTaskPane.Name = "CmdTaskPane";
            this.CmdTaskPane.ShowImage = true;
            this.CmdTaskPane.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.CmdTaskPane_Click);
            // 
            // group1
            // 
            this.group1.Items.Add(this.cmd_Import_Historical_Data);
            this.group1.Items.Add(this.Cmd_Import_Master_Data);
            this.group1.Label = "Import";
            this.group1.Name = "group1";
            // 
            // cmd_Import_Historical_Data
            // 
            this.cmd_Import_Historical_Data.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.cmd_Import_Historical_Data.Image = global::EXCEL_ADDINS.Properties.Resources.Import_001;
            this.cmd_Import_Historical_Data.Label = "Import historical data";
            this.cmd_Import_Historical_Data.Name = "cmd_Import_Historical_Data";
            this.cmd_Import_Historical_Data.ShowImage = true;
            this.cmd_Import_Historical_Data.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.cmd_Import_Historical_Data_Click);
            // 
            // Cmd_Import_Master_Data
            // 
            this.Cmd_Import_Master_Data.ControlSize = Microsoft.Office.Core.RibbonControlSize.RibbonControlSizeLarge;
            this.Cmd_Import_Master_Data.Image = global::EXCEL_ADDINS.Properties.Resources.Master_Data;
            this.Cmd_Import_Master_Data.Label = "Import Master Data";
            this.Cmd_Import_Master_Data.Name = "Cmd_Import_Master_Data";
            this.Cmd_Import_Master_Data.ShowImage = true;
            this.Cmd_Import_Master_Data.Click += new Microsoft.Office.Tools.Ribbon.RibbonControlEventHandler(this.Cmd_Import_Master_Data_Click);
            // 
            // Ribbon1
            // 
            this.Name = "Ribbon1";
            this.RibbonType = "Microsoft.Excel.Workbook";
            this.Tabs.Add(this.tab1);
            this.Load += new Microsoft.Office.Tools.Ribbon.RibbonUIEventHandler(this.Ribbon1_Load);
            this.tab1.ResumeLayout(false);
            this.tab1.PerformLayout();
            this.group2.ResumeLayout(false);
            this.group2.PerformLayout();
            this.group1.ResumeLayout(false);
            this.group1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        internal Microsoft.Office.Tools.Ribbon.RibbonTab tab1;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup group1;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton Cmd_Import_Master_Data;
        internal Microsoft.Office.Tools.Ribbon.RibbonGroup group2;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton CmdRefreshHostName;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton button1;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton CmdOpenWF;
        internal Microsoft.Office.Tools.Ribbon.RibbonButton CmdTaskPane;
        public Microsoft.Office.Tools.Ribbon.RibbonButton cmd_Import_Historical_Data;
    }

    partial class ThisRibbonCollection
    {
        internal Ribbon1 Ribbon1
        {
            get { return this.GetRibbon<Ribbon1>(); }
        }
    }
}
