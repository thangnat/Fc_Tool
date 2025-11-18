namespace WinFormsApp2
{
    partial class Frm_MM_master
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
            CmdLoadData = new DevExpress.XtraEditors.SimpleButton();
            gridControl1 = new GridControl();
            gridView1 = new GridControl.GridViewLaptrinhVB();
            ((System.ComponentModel.ISupportInitialize)gridControl1).BeginInit();
            ((System.ComponentModel.ISupportInitialize)gridView1).BeginInit();
            SuspendLayout();
            // 
            // CmdLoadData
            // 
            CmdLoadData.Location = new Point(15, 12);
            CmdLoadData.Name = "CmdLoadData";
            CmdLoadData.Size = new Size(64, 20);
            CmdLoadData.TabIndex = 0;
            CmdLoadData.Text = "Load Data";
            CmdLoadData.Click += CmdLoadData_Click;
            // 
            // gridControl1
            // 
            gridControl1.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            gridControl1.Location = new Point(3, 45);
            gridControl1.MainView = gridView1;
            gridControl1.Name = "gridControl1";
            gridControl1.Size = new Size(681, 343);
            gridControl1.TabIndex = 1;
            gridControl1.ViewCollection.AddRange(new DevExpress.XtraGrid.Views.Base.BaseView[] { gridView1 });
            // 
            // gridView1
            // 
            gridView1.Appearance.EvenRow.BackColor = Color.FromArgb(192, 255, 192);
            gridView1.Appearance.EvenRow.Options.UseBackColor = true;
            gridView1.DetailHeight = 303;
            gridView1.GridControl = gridControl1;
            gridView1.IndicatorWidth = 43;
            gridView1.Name = "gridView1";
            gridView1.OptionsSelection.CheckBoxSelectorColumnWidth = 26;
            gridView1.OptionsView.EnableAppearanceEvenRow = true;
            gridView1.OptionsView.ShowGroupPanel = false;
            // 
            // Frm_MM_master
            // 
            AutoScaleDimensions = new SizeF(6F, 13F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(686, 390);
            Controls.Add(gridControl1);
            Controls.Add(CmdLoadData);
            Name = "Frm_MM_master";
            Text = "Frm_MM_master";
            Load += Frm_MM_master_Load;
            ((System.ComponentModel.ISupportInitialize)gridControl1).EndInit();
            ((System.ComponentModel.ISupportInitialize)gridView1).EndInit();
            ResumeLayout(false);
        }

        #endregion

        private DevExpress.XtraEditors.SimpleButton CmdLoadData;
        private GridControl gridControl1;
        private GridControl.GridViewLaptrinhVB gridView1;
    }
}