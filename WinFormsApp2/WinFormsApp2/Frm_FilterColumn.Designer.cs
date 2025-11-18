namespace WinFormsApp2
{
    partial class Frm_FilterColumn
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
            groupBox1 = new GroupBox();
            layoutControl1 = new DevExpress.XtraLayout.LayoutControl();
            chkSelectedAll = new DevExpress.XtraEditors.CheckEdit();
            cmdApply = new DevExpress.XtraEditors.SimpleButton();
            gridControl1 = new DevExpress.XtraGrid.GridControl();
            gridView1 = new DevExpress.XtraGrid.Views.Grid.GridView();
            ColListGroupColumn = new DevExpress.XtraGrid.Columns.GridColumn();
            ColListColumn = new DevExpress.XtraGrid.Columns.GridColumn();
            ColAllow_Show = new DevExpress.XtraGrid.Columns.GridColumn();
            Root = new DevExpress.XtraLayout.LayoutControlGroup();
            layoutControlItem1 = new DevExpress.XtraLayout.LayoutControlItem();
            layoutControlItem2 = new DevExpress.XtraLayout.LayoutControlItem();
            emptySpaceItem1 = new DevExpress.XtraLayout.EmptySpaceItem();
            layoutControlItem3 = new DevExpress.XtraLayout.LayoutControlItem();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)layoutControl1).BeginInit();
            layoutControl1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)chkSelectedAll.Properties).BeginInit();
            ((System.ComponentModel.ISupportInitialize)gridControl1).BeginInit();
            ((System.ComponentModel.ISupportInitialize)gridView1).BeginInit();
            ((System.ComponentModel.ISupportInitialize)Root).BeginInit();
            ((System.ComponentModel.ISupportInitialize)layoutControlItem1).BeginInit();
            ((System.ComponentModel.ISupportInitialize)layoutControlItem2).BeginInit();
            ((System.ComponentModel.ISupportInitialize)emptySpaceItem1).BeginInit();
            ((System.ComponentModel.ISupportInitialize)layoutControlItem3).BeginInit();
            SuspendLayout();
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(layoutControl1);
            groupBox1.Dock = DockStyle.Fill;
            groupBox1.Font = new Font("Tahoma", 8.25F, FontStyle.Bold, GraphicsUnit.Point);
            groupBox1.Location = new Point(0, 0);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(433, 497);
            groupBox1.TabIndex = 0;
            groupBox1.TabStop = false;
            groupBox1.Text = "select column shows";
            // 
            // layoutControl1
            // 
            layoutControl1.Controls.Add(chkSelectedAll);
            layoutControl1.Controls.Add(cmdApply);
            layoutControl1.Controls.Add(gridControl1);
            layoutControl1.Dock = DockStyle.Fill;
            layoutControl1.Location = new Point(3, 17);
            layoutControl1.Name = "layoutControl1";
            layoutControl1.Root = Root;
            layoutControl1.Size = new Size(427, 477);
            layoutControl1.TabIndex = 1;
            layoutControl1.Text = "layoutControl1";
            // 
            // chkSelectedAll
            // 
            chkSelectedAll.Location = new Point(12, 443);
            chkSelectedAll.Name = "chkSelectedAll";
            chkSelectedAll.Properties.Caption = "Selected All";
            chkSelectedAll.Size = new Size(144, 20);
            chkSelectedAll.StyleController = layoutControl1;
            chkSelectedAll.TabIndex = 4;
            chkSelectedAll.CheckedChanged += chkSelectedAll_CheckedChanged;
            // 
            // cmdApply
            // 
            cmdApply.Appearance.BackColor = Color.FromArgb(255, 192, 192);
            cmdApply.Appearance.Font = new Font("Tahoma", 8.25F, FontStyle.Bold, GraphicsUnit.Point);
            cmdApply.Appearance.Options.UseBackColor = true;
            cmdApply.Appearance.Options.UseFont = true;
            cmdApply.Location = new Point(324, 443);
            cmdApply.Name = "cmdApply";
            cmdApply.Size = new Size(91, 22);
            cmdApply.StyleController = layoutControl1;
            cmdApply.TabIndex = 2;
            cmdApply.Text = "Apply";
            cmdApply.Click += cmdApply_Click;
            // 
            // gridControl1
            // 
            gridControl1.Location = new Point(12, 12);
            gridControl1.MainView = gridView1;
            gridControl1.Name = "gridControl1";
            gridControl1.Size = new Size(403, 427);
            gridControl1.TabIndex = 0;
            gridControl1.ViewCollection.AddRange(new DevExpress.XtraGrid.Views.Base.BaseView[] { gridView1 });
            // 
            // gridView1
            // 
            gridView1.Columns.AddRange(new DevExpress.XtraGrid.Columns.GridColumn[] { ColListGroupColumn, ColListColumn, ColAllow_Show });
            gridView1.GridControl = gridControl1;
            gridView1.Name = "gridView1";
            gridView1.OptionsSelection.MultiSelect = true;
            gridView1.OptionsSelection.MultiSelectMode = DevExpress.XtraGrid.Views.Grid.GridMultiSelectMode.CellSelect;
            gridView1.OptionsView.ColumnAutoWidth = false;
            gridView1.OptionsView.ShowAutoFilterRow = true;
            gridView1.OptionsView.ShowGroupPanel = false;
            // 
            // ColListGroupColumn
            // 
            ColListGroupColumn.Caption = "List Group Column";
            ColListGroupColumn.FieldName = "List Group Column";
            ColListGroupColumn.Name = "ColListGroupColumn";
            ColListGroupColumn.Visible = true;
            ColListGroupColumn.VisibleIndex = 0;
            ColListGroupColumn.Width = 354;
            // 
            // ColListColumn
            // 
            ColListColumn.Caption = "List Column";
            ColListColumn.FieldName = "List Column";
            ColListColumn.Name = "ColListColumn";
            ColListColumn.Width = 327;
            // 
            // ColAllow_Show
            // 
            ColAllow_Show.Caption = "Allow Show";
            ColAllow_Show.FieldName = "Allow_Show";
            ColAllow_Show.Name = "ColAllow_Show";
            // 
            // Root
            // 
            Root.EnableIndentsWithoutBorders = DevExpress.Utils.DefaultBoolean.True;
            Root.GroupBordersVisible = false;
            Root.Items.AddRange(new DevExpress.XtraLayout.BaseLayoutItem[] { layoutControlItem1, layoutControlItem2, emptySpaceItem1, layoutControlItem3 });
            Root.Name = "Root";
            Root.Size = new Size(427, 477);
            Root.TextVisible = false;
            // 
            // layoutControlItem1
            // 
            layoutControlItem1.Control = gridControl1;
            layoutControlItem1.Location = new Point(0, 0);
            layoutControlItem1.Name = "layoutControlItem1";
            layoutControlItem1.Size = new Size(407, 431);
            layoutControlItem1.TextSize = new Size(0, 0);
            layoutControlItem1.TextVisible = false;
            // 
            // layoutControlItem2
            // 
            layoutControlItem2.Control = cmdApply;
            layoutControlItem2.Location = new Point(312, 431);
            layoutControlItem2.MaxSize = new Size(95, 26);
            layoutControlItem2.MinSize = new Size(95, 26);
            layoutControlItem2.Name = "layoutControlItem2";
            layoutControlItem2.Size = new Size(95, 26);
            layoutControlItem2.SizeConstraintsType = DevExpress.XtraLayout.SizeConstraintsType.Custom;
            layoutControlItem2.TextSize = new Size(0, 0);
            layoutControlItem2.TextVisible = false;
            // 
            // emptySpaceItem1
            // 
            emptySpaceItem1.AllowHotTrack = false;
            emptySpaceItem1.Location = new Point(148, 431);
            emptySpaceItem1.Name = "emptySpaceItem1";
            emptySpaceItem1.Size = new Size(164, 26);
            emptySpaceItem1.TextSize = new Size(0, 0);
            // 
            // layoutControlItem3
            // 
            layoutControlItem3.Control = chkSelectedAll;
            layoutControlItem3.Location = new Point(0, 431);
            layoutControlItem3.Name = "layoutControlItem3";
            layoutControlItem3.Size = new Size(148, 26);
            layoutControlItem3.TextSize = new Size(0, 0);
            layoutControlItem3.TextVisible = false;
            // 
            // Frm_FilterColumn
            // 
            AutoScaleDimensions = new SizeF(6F, 13F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(433, 497);
            Controls.Add(groupBox1);
            Name = "Frm_FilterColumn";
            Text = "Frm_FilterColumn";
            Load += Frm_FilterColumn_Load;
            groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)layoutControl1).EndInit();
            layoutControl1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)chkSelectedAll.Properties).EndInit();
            ((System.ComponentModel.ISupportInitialize)gridControl1).EndInit();
            ((System.ComponentModel.ISupportInitialize)gridView1).EndInit();
            ((System.ComponentModel.ISupportInitialize)Root).EndInit();
            ((System.ComponentModel.ISupportInitialize)layoutControlItem1).EndInit();
            ((System.ComponentModel.ISupportInitialize)layoutControlItem2).EndInit();
            ((System.ComponentModel.ISupportInitialize)emptySpaceItem1).EndInit();
            ((System.ComponentModel.ISupportInitialize)layoutControlItem3).EndInit();
            ResumeLayout(false);
        }

        #endregion

        private GroupBox groupBox1;
        private DevExpress.XtraGrid.GridControl gridControl1;
        private DevExpress.XtraGrid.Views.Grid.GridView gridView1;
        private DevExpress.XtraGrid.Columns.GridColumn ColListGroupColumn;
        private DevExpress.XtraLayout.LayoutControl layoutControl1;
        private DevExpress.XtraEditors.SimpleButton cmdApply;
        private DevExpress.XtraGrid.Columns.GridColumn ColListColumn;
        private DevExpress.XtraLayout.LayoutControlGroup Root;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem1;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem2;
        private DevExpress.XtraLayout.EmptySpaceItem emptySpaceItem1;
        private DevExpress.XtraEditors.CheckEdit chkSelectedAll;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem3;
        private DevExpress.XtraGrid.Columns.GridColumn ColAllow_Show;
    }
}