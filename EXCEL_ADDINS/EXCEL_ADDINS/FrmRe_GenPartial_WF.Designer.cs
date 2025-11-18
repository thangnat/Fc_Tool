
namespace EXCEL_ADDINS
{
    partial class FrmRe_GenPartial_WF
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.chkSelected = new System.Windows.Forms.CheckBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.LbProcessing = new System.Windows.Forms.Label();
            this.txtprocessStatus = new System.Windows.Forms.RichTextBox();
            this.chkRefresh_All_WF = new System.Windows.Forms.CheckBox();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.refreshWFToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.justRefreshWFFCALLColumnToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.testSignatureToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.chkAllowshowerrorInfo = new System.Windows.Forms.CheckBox();
            this.CmdCancel = new System.Windows.Forms.Button();
            this.cmdSave = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox1.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.groupBox1.Controls.Add(this.chkSelected);
            this.groupBox1.Controls.Add(this.splitContainer1);
            this.groupBox1.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.groupBox1.Location = new System.Drawing.Point(0, 33);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.groupBox1.Size = new System.Drawing.Size(1549, 550);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "List task";
            // 
            // chkSelected
            // 
            this.chkSelected.AutoSize = true;
            this.chkSelected.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.chkSelected.ForeColor = System.Drawing.Color.Maroon;
            this.chkSelected.Location = new System.Drawing.Point(4, -1);
            this.chkSelected.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.chkSelected.Name = "chkSelected";
            this.chkSelected.Size = new System.Drawing.Size(116, 21);
            this.chkSelected.TabIndex = 1;
            this.chkSelected.Text = "Selected All";
            this.chkSelected.UseVisualStyleBackColor = true;
            this.chkSelected.CheckedChanged += new System.EventHandler(this.chkSelected_CheckedChanged);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(4, 19);
            this.splitContainer1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.dataGridView1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.LbProcessing);
            this.splitContainer1.Panel2.Controls.Add(this.txtprocessStatus);
            this.splitContainer1.Size = new System.Drawing.Size(1541, 527);
            this.splitContainer1.SplitterDistance = 937;
            this.splitContainer1.SplitterWidth = 5;
            this.splitContainer1.TabIndex = 0;
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dataGridView1.Location = new System.Drawing.Point(0, 0);
            this.dataGridView1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersWidth = 51;
            this.dataGridView1.Size = new System.Drawing.Size(937, 527);
            this.dataGridView1.TabIndex = 0;
            this.dataGridView1.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellClick);
            this.dataGridView1.CellValueChanged += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellValueChanged);
            this.dataGridView1.DoubleClick += new System.EventHandler(this.dataGridView1_DoubleClick);
            // 
            // LbProcessing
            // 
            this.LbProcessing.AutoSize = true;
            this.LbProcessing.BackColor = System.Drawing.Color.Lime;
            this.LbProcessing.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LbProcessing.Location = new System.Drawing.Point(105, 151);
            this.LbProcessing.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.LbProcessing.Name = "LbProcessing";
            this.LbProcessing.Size = new System.Drawing.Size(210, 36);
            this.LbProcessing.TabIndex = 4;
            this.LbProcessing.Text = "Processing.../";
            // 
            // txtprocessStatus
            // 
            this.txtprocessStatus.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.txtprocessStatus.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtprocessStatus.Location = new System.Drawing.Point(0, 0);
            this.txtprocessStatus.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.txtprocessStatus.Name = "txtprocessStatus";
            this.txtprocessStatus.Size = new System.Drawing.Size(599, 527);
            this.txtprocessStatus.TabIndex = 0;
            this.txtprocessStatus.Text = "";
            // 
            // chkRefresh_All_WF
            // 
            this.chkRefresh_All_WF.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.chkRefresh_All_WF.AutoSize = true;
            this.chkRefresh_All_WF.Location = new System.Drawing.Point(179, 600);
            this.chkRefresh_All_WF.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.chkRefresh_All_WF.Name = "chkRefresh_All_WF";
            this.chkRefresh_All_WF.Size = new System.Drawing.Size(118, 20);
            this.chkRefresh_All_WF.TabIndex = 2;
            this.chkRefresh_All_WF.Text = "Refresh All WF";
            this.chkRefresh_All_WF.UseVisualStyleBackColor = true;
            this.chkRefresh_All_WF.Visible = false;
            // 
            // menuStrip1
            // 
            this.menuStrip1.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(1551, 28);
            this.menuStrip1.TabIndex = 3;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.refreshWFToolStripMenuItem,
            this.justRefreshWFFCALLColumnToolStripMenuItem,
            this.testSignatureToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(46, 24);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // refreshWFToolStripMenuItem
            // 
            this.refreshWFToolStripMenuItem.Name = "refreshWFToolStripMenuItem";
            this.refreshWFToolStripMenuItem.Size = new System.Drawing.Size(293, 26);
            this.refreshWFToolStripMenuItem.Text = "Just refresh WF FC";
            this.refreshWFToolStripMenuItem.Click += new System.EventHandler(this.refreshWFToolStripMenuItem_Click);
            // 
            // justRefreshWFFCALLColumnToolStripMenuItem
            // 
            this.justRefreshWFFCALLColumnToolStripMenuItem.BackColor = System.Drawing.Color.MistyRose;
            this.justRefreshWFFCALLColumnToolStripMenuItem.Name = "justRefreshWFFCALLColumnToolStripMenuItem";
            this.justRefreshWFFCALLColumnToolStripMenuItem.Size = new System.Drawing.Size(293, 26);
            this.justRefreshWFFCALLColumnToolStripMenuItem.Text = "Just refresh WF FC ALL Column";
            this.justRefreshWFFCALLColumnToolStripMenuItem.Click += new System.EventHandler(this.justRefreshWFFCALLColumnToolStripMenuItem_Click);
            // 
            // testSignatureToolStripMenuItem
            // 
            this.testSignatureToolStripMenuItem.Name = "testSignatureToolStripMenuItem";
            this.testSignatureToolStripMenuItem.Size = new System.Drawing.Size(293, 26);
            this.testSignatureToolStripMenuItem.Text = "test signature";
            this.testSignatureToolStripMenuItem.Click += new System.EventHandler(this.testSignatureToolStripMenuItem_Click);
            // 
            // chkAllowshowerrorInfo
            // 
            this.chkAllowshowerrorInfo.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.chkAllowshowerrorInfo.AutoSize = true;
            this.chkAllowshowerrorInfo.Location = new System.Drawing.Point(10, 600);
            this.chkAllowshowerrorInfo.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.chkAllowshowerrorInfo.Name = "chkAllowshowerrorInfo";
            this.chkAllowshowerrorInfo.Size = new System.Drawing.Size(150, 20);
            this.chkAllowshowerrorInfo.TabIndex = 2;
            this.chkAllowshowerrorInfo.Text = "Allow show error info";
            this.chkAllowshowerrorInfo.UseVisualStyleBackColor = true;
            // 
            // CmdCancel
            // 
            this.CmdCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.CmdCancel.Image = global::EXCEL_ADDINS.Properties.Resources._317717_operating_system_windows_icon;
            this.CmdCancel.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.CmdCancel.Location = new System.Drawing.Point(1419, 591);
            this.CmdCancel.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.CmdCancel.Name = "CmdCancel";
            this.CmdCancel.Size = new System.Drawing.Size(127, 41);
            this.CmdCancel.TabIndex = 1;
            this.CmdCancel.Text = "Cancel";
            this.CmdCancel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.CmdCancel.UseVisualStyleBackColor = true;
            this.CmdCancel.Click += new System.EventHandler(this.CmdCancel_Click);
            // 
            // cmdSave
            // 
            this.cmdSave.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdSave.Image = global::EXCEL_ADDINS.Properties.Resources.save_32_01;
            this.cmdSave.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.cmdSave.Location = new System.Drawing.Point(1284, 591);
            this.cmdSave.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.cmdSave.Name = "cmdSave";
            this.cmdSave.Size = new System.Drawing.Size(137, 41);
            this.cmdSave.TabIndex = 1;
            this.cmdSave.Text = "Gen FC";
            this.cmdSave.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.cmdSave.UseVisualStyleBackColor = true;
            this.cmdSave.Click += new System.EventHandler(this.CmdSave_Click);
            this.cmdSave.Enter += new System.EventHandler(this.cmdSave_Enter);
            // 
            // FrmRe_GenPartial_WF
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.InactiveCaption;
            this.ClientSize = new System.Drawing.Size(1551, 635);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.chkAllowshowerrorInfo);
            this.Controls.Add(this.chkRefresh_All_WF);
            this.Controls.Add(this.CmdCancel);
            this.Controls.Add(this.cmdSave);
            this.Controls.Add(this.menuStrip1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmRe_GenPartial_WF";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Re Gen Partial WF";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FrmRe_GenPartial_WF_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmRe_GenPartial_WF_FormClosed);
            this.Load += new System.EventHandler(this.FrmRe_GenPartial_WF_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.RichTextBox txtprocessStatus;
        private System.Windows.Forms.Button cmdSave;
        private System.Windows.Forms.CheckBox chkSelected;
        private System.Windows.Forms.CheckBox chkRefresh_All_WF;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem refreshWFToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem justRefreshWFFCALLColumnToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem testSignatureToolStripMenuItem;
        private System.Windows.Forms.CheckBox chkAllowshowerrorInfo;
        private System.Windows.Forms.Button CmdCancel;
        private System.Windows.Forms.Label LbProcessing;
    }
}