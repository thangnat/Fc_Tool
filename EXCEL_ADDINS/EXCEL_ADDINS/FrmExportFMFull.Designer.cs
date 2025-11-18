
namespace EXCEL_ADDINS
{
    partial class FrmExportFMFull
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
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.panel1 = new System.Windows.Forms.Panel();
            this.dataGridView2 = new System.Windows.Forms.DataGridView();
            this.cmdView = new System.Windows.Forms.Button();
            this.txtTimseries = new System.Windows.Forms.TextBox();
            this.rOFFLINE = new System.Windows.Forms.RadioButton();
            this.rONLINE = new System.Windows.Forms.RadioButton();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.cmdSubmit = new System.Windows.Forms.Button();
            this.ChkSelectedAll = new System.Windows.Forms.CheckBox();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).BeginInit();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(3, 12);
            this.dataGridView1.MultiSelect = false;
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(329, 391);
            this.dataGridView1.TabIndex = 0;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            this.dataGridView1.Click += new System.EventHandler(this.dataGridView1_Click);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Location = new System.Drawing.Point(814, 46);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.panel1);
            this.splitContainer1.Panel2.Controls.Add(this.dataGridView2);
            this.splitContainer1.Panel2.Controls.Add(this.cmdView);
            this.splitContainer1.Panel2.Controls.Add(this.txtTimseries);
            this.splitContainer1.Panel2.Controls.Add(this.rOFFLINE);
            this.splitContainer1.Panel2.Controls.Add(this.rONLINE);
            this.splitContainer1.Size = new System.Drawing.Size(464, 296);
            this.splitContainer1.SplitterDistance = 99;
            this.splitContainer1.TabIndex = 1;
            this.splitContainer1.Visible = false;
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panel1.BackColor = System.Drawing.Color.Navy;
            this.panel1.Location = new System.Drawing.Point(3, 3);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(355, 48);
            this.panel1.TabIndex = 3;
            // 
            // dataGridView2
            // 
            this.dataGridView2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dataGridView2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView2.Location = new System.Drawing.Point(3, 57);
            this.dataGridView2.Name = "dataGridView2";
            this.dataGridView2.Size = new System.Drawing.Size(355, 236);
            this.dataGridView2.TabIndex = 2;
            // 
            // cmdView
            // 
            this.cmdView.BackColor = System.Drawing.SystemColors.Info;
            this.cmdView.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmdView.ForeColor = System.Drawing.Color.Navy;
            this.cmdView.Image = global::EXCEL_ADDINS.Properties.Resources.Filter_24;
            this.cmdView.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.cmdView.Location = new System.Drawing.Point(143, 177);
            this.cmdView.Name = "cmdView";
            this.cmdView.Size = new System.Drawing.Size(80, 33);
            this.cmdView.TabIndex = 1;
            this.cmdView.Text = "View";
            this.cmdView.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.cmdView.UseVisualStyleBackColor = false;
            this.cmdView.Click += new System.EventHandler(this.cmdView_Click);
            // 
            // txtTimseries
            // 
            this.txtTimseries.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtTimseries.BackColor = System.Drawing.SystemColors.Info;
            this.txtTimseries.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtTimseries.ForeColor = System.Drawing.Color.Navy;
            this.txtTimseries.Location = new System.Drawing.Point(256, 148);
            this.txtTimseries.Multiline = true;
            this.txtTimseries.Name = "txtTimseries";
            this.txtTimseries.Size = new System.Drawing.Size(0, 33);
            this.txtTimseries.TabIndex = 2;
            this.txtTimseries.TextChanged += new System.EventHandler(this.txtTimseries_TextChanged);
            // 
            // rOFFLINE
            // 
            this.rOFFLINE.AutoSize = true;
            this.rOFFLINE.ForeColor = System.Drawing.Color.White;
            this.rOFFLINE.Location = new System.Drawing.Point(68, 193);
            this.rOFFLINE.Name = "rOFFLINE";
            this.rOFFLINE.Size = new System.Drawing.Size(69, 17);
            this.rOFFLINE.TabIndex = 2;
            this.rOFFLINE.TabStop = true;
            this.rOFFLINE.Text = "OFFLINE";
            this.rOFFLINE.UseVisualStyleBackColor = true;
            this.rOFFLINE.CheckedChanged += new System.EventHandler(this.rOFFLINE_CheckedChanged);
            // 
            // rONLINE
            // 
            this.rONLINE.AutoSize = true;
            this.rONLINE.ForeColor = System.Drawing.Color.White;
            this.rONLINE.Location = new System.Drawing.Point(68, 174);
            this.rONLINE.Name = "rONLINE";
            this.rONLINE.Size = new System.Drawing.Size(65, 17);
            this.rONLINE.TabIndex = 2;
            this.rONLINE.TabStop = true;
            this.rONLINE.Text = "ONLINE";
            this.rONLINE.UseVisualStyleBackColor = true;
            this.rONLINE.CheckedChanged += new System.EventHandler(this.rONLINE_CheckedChanged);
            // 
            // groupBox1
            // 
            this.groupBox1.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.groupBox1.Controls.Add(this.cmdSubmit);
            this.groupBox1.Controls.Add(this.ChkSelectedAll);
            this.groupBox1.Controls.Add(this.dataGridView1);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(338, 452);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            // 
            // cmdSubmit
            // 
            this.cmdSubmit.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdSubmit.BackColor = System.Drawing.SystemColors.Info;
            this.cmdSubmit.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmdSubmit.ForeColor = System.Drawing.Color.Navy;
            this.cmdSubmit.Image = global::EXCEL_ADDINS.Properties.Resources.Submit_32;
            this.cmdSubmit.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.cmdSubmit.Location = new System.Drawing.Point(220, 409);
            this.cmdSubmit.Name = "cmdSubmit";
            this.cmdSubmit.Size = new System.Drawing.Size(112, 37);
            this.cmdSubmit.TabIndex = 1;
            this.cmdSubmit.Text = "Submit";
            this.cmdSubmit.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.cmdSubmit.UseVisualStyleBackColor = false;
            this.cmdSubmit.Click += new System.EventHandler(this.cmdSubmit_Click);
            // 
            // ChkSelectedAll
            // 
            this.ChkSelectedAll.AutoSize = true;
            this.ChkSelectedAll.BackColor = System.Drawing.Color.White;
            this.ChkSelectedAll.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChkSelectedAll.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
            this.ChkSelectedAll.Location = new System.Drawing.Point(42, 14);
            this.ChkSelectedAll.Name = "ChkSelectedAll";
            this.ChkSelectedAll.Size = new System.Drawing.Size(94, 17);
            this.ChkSelectedAll.TabIndex = 1;
            this.ChkSelectedAll.Text = "Selected All";
            this.ChkSelectedAll.UseVisualStyleBackColor = false;
            this.ChkSelectedAll.CheckedChanged += new System.EventHandler(this.ChkSelectedAll_CheckedChanged);
            // 
            // FrmExportFMFull
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(338, 452);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.splitContainer1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "FrmExportFMFull";
            this.Text = "Export FM Management";
            this.Load += new System.EventHandler(this.FrmExportFMFull_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.Button cmdSubmit;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.DataGridView dataGridView2;
        private System.Windows.Forms.Button cmdView;
        private System.Windows.Forms.TextBox txtTimseries;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.CheckBox ChkSelectedAll;
        private System.Windows.Forms.RadioButton rOFFLINE;
        private System.Windows.Forms.RadioButton rONLINE;
    }
}