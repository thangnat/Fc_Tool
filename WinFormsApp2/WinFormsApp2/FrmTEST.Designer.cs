namespace WinFormsApp2
{
    partial class FrmTEST
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
            simpleButton1 = new DevExpress.XtraEditors.SimpleButton();
            SuspendLayout();
            // 
            // simpleButton1
            // 
            simpleButton1.Location = new Point(12, 12);
            simpleButton1.Name = "simpleButton1";
            simpleButton1.Size = new Size(75, 23);
            simpleButton1.TabIndex = 0;
            simpleButton1.Text = "simpleButton1";
            simpleButton1.Click += simpleButton1_Click;
            // 
            // FrmTEST
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(931, 357);
            Controls.Add(simpleButton1);
            Name = "FrmTEST";
            Text = "FrmTEST";
            Load += FrmTEST_Load;
            ResumeLayout(false);
        }

        #endregion

        private DevExpress.XtraEditors.SimpleButton simpleButton1;
    }
}