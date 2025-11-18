
namespace EXCEL_ADDINS
{
    partial class FrmAlert
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
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.txtscript = new System.Windows.Forms.TextBox();
            this.dataGridViewSI_HIS_FC = new System.Windows.Forms.DataGridView();
            this.cmdMasterData = new System.Windows.Forms.Button();
            this.cmdMissingBom = new System.Windows.Forms.Button();
            this.cmdRSP = new System.Windows.Forms.Button();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.flowLayoutPanel2 = new System.Windows.Forms.FlowLayoutPanel();
            this.cmdDuplicate_Master_Data = new System.Windows.Forms.Button();
            this.cmdInconsistency = new System.Windows.Forms.Button();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.dataGridView2 = new System.Windows.Forms.DataGridView();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.flowLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewSI_HIS_FC)).BeginInit();
            this.groupBox3.SuspendLayout();
            this.flowLayoutPanel2.SuspendLayout();
            this.groupBox4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dataGridView1.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.dataGridView1.Location = new System.Drawing.Point(3, 16);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.Size = new System.Drawing.Size(388, 465);
            this.dataGridView1.TabIndex = 0;
            this.dataGridView1.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellClick);
            this.dataGridView1.Click += new System.EventHandler(this.dataGridView1_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.groupBox1.Controls.Add(this.dataGridView1);
            this.groupBox1.Controls.Add(this.flowLayoutPanel1);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
            this.groupBox1.Location = new System.Drawing.Point(2, 65);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(394, 484);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "List Function status run";
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.Controls.Add(this.groupBox4);
            this.groupBox2.Controls.Add(this.dataGridViewSI_HIS_FC);
            this.groupBox2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
            this.groupBox2.Location = new System.Drawing.Point(402, 68);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(692, 481);
            this.groupBox2.TabIndex = 2;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Alert detail";
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.flowLayoutPanel1.BackColor = System.Drawing.Color.Blue;
            this.flowLayoutPanel1.Controls.Add(this.txtscript);
            this.flowLayoutPanel1.Location = new System.Drawing.Point(231, 168);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(111, 95);
            this.flowLayoutPanel1.TabIndex = 2;
            this.flowLayoutPanel1.Visible = false;
            // 
            // txtscript
            // 
            this.txtscript.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtscript.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.txtscript.Location = new System.Drawing.Point(3, 3);
            this.txtscript.Name = "txtscript";
            this.txtscript.Size = new System.Drawing.Size(1060, 20);
            this.txtscript.TabIndex = 5;
            // 
            // dataGridViewSI_HIS_FC
            // 
            this.dataGridViewSI_HIS_FC.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dataGridViewSI_HIS_FC.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridViewSI_HIS_FC.Location = new System.Drawing.Point(3, 16);
            this.dataGridViewSI_HIS_FC.Name = "dataGridViewSI_HIS_FC";
            this.dataGridViewSI_HIS_FC.Size = new System.Drawing.Size(686, 261);
            this.dataGridViewSI_HIS_FC.TabIndex = 0;
            // 
            // cmdMasterData
            // 
            this.cmdMasterData.BackColor = System.Drawing.Color.Red;
            this.cmdMasterData.FlatAppearance.BorderColor = System.Drawing.Color.Red;
            this.cmdMasterData.ForeColor = System.Drawing.Color.White;
            this.cmdMasterData.Location = new System.Drawing.Point(3, 3);
            this.cmdMasterData.Name = "cmdMasterData";
            this.cmdMasterData.Size = new System.Drawing.Size(148, 23);
            this.cmdMasterData.TabIndex = 1;
            this.cmdMasterData.Text = "Missing Master Data";
            this.cmdMasterData.UseVisualStyleBackColor = false;
            this.cmdMasterData.Click += new System.EventHandler(this.cmdMasterData_Click);
            // 
            // cmdMissingBom
            // 
            this.cmdMissingBom.BackColor = System.Drawing.Color.Red;
            this.cmdMissingBom.FlatAppearance.BorderColor = System.Drawing.Color.Red;
            this.cmdMissingBom.ForeColor = System.Drawing.Color.White;
            this.cmdMissingBom.Location = new System.Drawing.Point(291, 3);
            this.cmdMissingBom.Name = "cmdMissingBom";
            this.cmdMissingBom.Size = new System.Drawing.Size(137, 23);
            this.cmdMissingBom.TabIndex = 2;
            this.cmdMissingBom.Text = "Missing BOM";
            this.cmdMissingBom.UseVisualStyleBackColor = false;
            this.cmdMissingBom.Click += new System.EventHandler(this.cmdMissingBom_Click);
            // 
            // cmdRSP
            // 
            this.cmdRSP.BackColor = System.Drawing.Color.Red;
            this.cmdRSP.FlatAppearance.BorderColor = System.Drawing.Color.Red;
            this.cmdRSP.ForeColor = System.Drawing.Color.White;
            this.cmdRSP.Location = new System.Drawing.Point(434, 3);
            this.cmdRSP.Name = "cmdRSP";
            this.cmdRSP.Size = new System.Drawing.Size(109, 23);
            this.cmdRSP.TabIndex = 4;
            this.cmdRSP.Text = "Missing RSP";
            this.cmdRSP.UseVisualStyleBackColor = false;
            this.cmdRSP.Click += new System.EventHandler(this.cmdRSP_Click);
            // 
            // groupBox3
            // 
            this.groupBox3.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox3.Controls.Add(this.flowLayoutPanel2);
            this.groupBox3.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
            this.groupBox3.Location = new System.Drawing.Point(2, 4);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(1092, 58);
            this.groupBox3.TabIndex = 3;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Error Alert";
            // 
            // flowLayoutPanel2
            // 
            this.flowLayoutPanel2.BackColor = System.Drawing.Color.Blue;
            this.flowLayoutPanel2.Controls.Add(this.cmdMasterData);
            this.flowLayoutPanel2.Controls.Add(this.cmdDuplicate_Master_Data);
            this.flowLayoutPanel2.Controls.Add(this.cmdMissingBom);
            this.flowLayoutPanel2.Controls.Add(this.cmdRSP);
            this.flowLayoutPanel2.Controls.Add(this.cmdInconsistency);
            this.flowLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.flowLayoutPanel2.Location = new System.Drawing.Point(3, 16);
            this.flowLayoutPanel2.Name = "flowLayoutPanel2";
            this.flowLayoutPanel2.Size = new System.Drawing.Size(1086, 39);
            this.flowLayoutPanel2.TabIndex = 0;
            // 
            // cmdDuplicate_Master_Data
            // 
            this.cmdDuplicate_Master_Data.BackColor = System.Drawing.Color.Red;
            this.cmdDuplicate_Master_Data.FlatAppearance.BorderColor = System.Drawing.Color.Red;
            this.cmdDuplicate_Master_Data.ForeColor = System.Drawing.Color.White;
            this.cmdDuplicate_Master_Data.Location = new System.Drawing.Point(157, 3);
            this.cmdDuplicate_Master_Data.Name = "cmdDuplicate_Master_Data";
            this.cmdDuplicate_Master_Data.Size = new System.Drawing.Size(128, 23);
            this.cmdDuplicate_Master_Data.TabIndex = 5;
            this.cmdDuplicate_Master_Data.Text = "Duplicate master data";
            this.cmdDuplicate_Master_Data.UseVisualStyleBackColor = false;
            this.cmdDuplicate_Master_Data.Click += new System.EventHandler(this.cmdDuplicate_Master_Data_Click);
            // 
            // cmdInconsistency
            // 
            this.cmdInconsistency.BackColor = System.Drawing.Color.Red;
            this.cmdInconsistency.FlatAppearance.BorderColor = System.Drawing.Color.Red;
            this.cmdInconsistency.ForeColor = System.Drawing.Color.White;
            this.cmdInconsistency.Location = new System.Drawing.Point(549, 3);
            this.cmdInconsistency.Name = "cmdInconsistency";
            this.cmdInconsistency.Size = new System.Drawing.Size(123, 23);
            this.cmdInconsistency.TabIndex = 6;
            this.cmdInconsistency.Text = "Inconsistency";
            this.cmdInconsistency.UseVisualStyleBackColor = false;
            this.cmdInconsistency.Click += new System.EventHandler(this.cmdInconsistency_Click);
            // 
            // groupBox4
            // 
            this.groupBox4.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox4.Controls.Add(this.dataGridView2);
            this.groupBox4.Location = new System.Drawing.Point(3, 283);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(686, 195);
            this.groupBox4.TabIndex = 3;
            this.groupBox4.TabStop = false;
            this.groupBox4.Text = "SOH, MTD SI";
            // 
            // dataGridView2
            // 
            this.dataGridView2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dataGridView2.Location = new System.Drawing.Point(3, 16);
            this.dataGridView2.Name = "dataGridView2";
            this.dataGridView2.Size = new System.Drawing.Size(680, 176);
            this.dataGridView2.TabIndex = 0;
            // 
            // FrmAlert
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.ClientSize = new System.Drawing.Size(1095, 553);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.groupBox3);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmAlert";
            this.Text = "Gen Alert ";
            this.Load += new System.EventHandler(this.FrmAlert_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.flowLayoutPanel1.ResumeLayout(false);
            this.flowLayoutPanel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewSI_HIS_FC)).EndInit();
            this.groupBox3.ResumeLayout(false);
            this.flowLayoutPanel2.ResumeLayout(false);
            this.groupBox4.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button cmdMasterData;
        private System.Windows.Forms.DataGridView dataGridViewSI_HIS_FC;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
        private System.Windows.Forms.Button cmdMissingBom;
        private System.Windows.Forms.Button cmdRSP;
        private System.Windows.Forms.TextBox txtscript;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel2;
        private System.Windows.Forms.Button cmdDuplicate_Master_Data;
        private System.Windows.Forms.Button cmdInconsistency;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.DataGridView dataGridView2;
    }
}