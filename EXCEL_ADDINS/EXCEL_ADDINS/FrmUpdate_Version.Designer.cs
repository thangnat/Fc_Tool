
namespace EXCEL_ADDINS
{
    partial class FrmUpdate_Version
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
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label2 = new System.Windows.Forms.Label();
            this.RichContent = new System.Windows.Forms.RichTextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.cmd1hour = new System.Windows.Forms.Button();
            this.cmd2hours = new System.Windows.Forms.Button();
            this.cmd4hours = new System.Windows.Forms.Button();
            this.cmdImmediate = new System.Windows.Forms.Button();
            this.flowLayoutPanel1.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.Controls.Add(this.groupBox1);
            this.flowLayoutPanel1.Controls.Add(this.cmd1hour);
            this.flowLayoutPanel1.Controls.Add(this.cmd2hours);
            this.flowLayoutPanel1.Controls.Add(this.cmd4hours);
            this.flowLayoutPanel1.Controls.Add(this.cmdImmediate);
            this.flowLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(544, 328);
            this.flowLayoutPanel1.TabIndex = 0;
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.RichContent);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.ForeColor = System.Drawing.Color.Navy;
            this.groupBox1.Location = new System.Drawing.Point(3, 3);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(541, 272);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Content";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
            this.label2.Location = new System.Drawing.Point(18, 57);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(413, 20);
            this.label2.TabIndex = 2;
            this.label2.Text = "(*) Sau khi cập nhật thành công vui lòng mở lại WF";
            // 
            // RichContent
            // 
            this.RichContent.BackColor = System.Drawing.SystemColors.Info;
            this.RichContent.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.RichContent.ForeColor = System.Drawing.Color.Navy;
            this.RichContent.Location = new System.Drawing.Point(9, 84);
            this.RichContent.Name = "RichContent";
            this.RichContent.ReadOnly = true;
            this.RichContent.Size = new System.Drawing.Size(520, 188);
            this.RichContent.TabIndex = 1;
            this.RichContent.Text = "";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(64)))), ((int)(((byte)(0)))));
            this.label1.Location = new System.Drawing.Point(18, 28);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(385, 20);
            this.label1.TabIndex = 0;
            this.label1.Text = "Tính năng mới giúp cải thiện ứng dụng FC Tool ";
            // 
            // cmd1hour
            // 
            this.cmd1hour.BackColor = System.Drawing.SystemColors.GradientActiveCaption;
            this.cmd1hour.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmd1hour.Location = new System.Drawing.Point(3, 281);
            this.cmd1hour.Name = "cmd1hour";
            this.cmd1hour.Size = new System.Drawing.Size(75, 35);
            this.cmd1hour.TabIndex = 2;
            this.cmd1hour.Text = "1 Hour";
            this.cmd1hour.UseVisualStyleBackColor = false;
            this.cmd1hour.Visible = false;
            this.cmd1hour.Click += new System.EventHandler(this.cmd1hour_Click);
            // 
            // cmd2hours
            // 
            this.cmd2hours.BackColor = System.Drawing.SystemColors.GradientActiveCaption;
            this.cmd2hours.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmd2hours.Location = new System.Drawing.Point(84, 281);
            this.cmd2hours.Name = "cmd2hours";
            this.cmd2hours.Size = new System.Drawing.Size(75, 35);
            this.cmd2hours.TabIndex = 3;
            this.cmd2hours.Text = "2 Hours";
            this.cmd2hours.UseVisualStyleBackColor = false;
            this.cmd2hours.Visible = false;
            this.cmd2hours.Click += new System.EventHandler(this.cmd2hours_Click);
            // 
            // cmd4hours
            // 
            this.cmd4hours.BackColor = System.Drawing.SystemColors.GradientActiveCaption;
            this.cmd4hours.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmd4hours.Location = new System.Drawing.Point(165, 281);
            this.cmd4hours.Name = "cmd4hours";
            this.cmd4hours.Size = new System.Drawing.Size(75, 35);
            this.cmd4hours.TabIndex = 4;
            this.cmd4hours.Text = "4 Hours";
            this.cmd4hours.UseVisualStyleBackColor = false;
            this.cmd4hours.Visible = false;
            this.cmd4hours.Click += new System.EventHandler(this.cmd4hours_Click);
            // 
            // cmdImmediate
            // 
            this.cmdImmediate.BackColor = System.Drawing.SystemColors.GradientActiveCaption;
            this.cmdImmediate.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmdImmediate.Location = new System.Drawing.Point(246, 281);
            this.cmdImmediate.Name = "cmdImmediate";
            this.cmdImmediate.Size = new System.Drawing.Size(115, 35);
            this.cmdImmediate.TabIndex = 5;
            this.cmdImmediate.Text = "Immediate";
            this.cmdImmediate.UseVisualStyleBackColor = false;
            this.cmdImmediate.Click += new System.EventHandler(this.cmdImmediate_Click);
            // 
            // FrmUpdate_Version
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.GradientInactiveCaption;
            this.ClientSize = new System.Drawing.Size(544, 328);
            this.Controls.Add(this.flowLayoutPanel1);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmUpdate_Version";
            this.Text = "FrmUpdate_Version";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmUpdate_Version_FormClosed);
            this.Load += new System.EventHandler(this.FrmUpdate_Version_Load);
            this.flowLayoutPanel1.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button cmd1hour;
        private System.Windows.Forms.Button cmd2hours;
        private System.Windows.Forms.Button cmd4hours;
        private System.Windows.Forms.Button cmdImmediate;
        private System.Windows.Forms.RichTextBox RichContent;
        private System.Windows.Forms.Label label2;
    }
}