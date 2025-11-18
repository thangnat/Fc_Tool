using DevExpress.XtraEditors;
using DevExpress.XtraEditors.Repository;
using DevExpress.XtraEditors.Registrator;
using System.ComponentModel;
using System.Windows.Forms;
using System.Drawing;
using DevExpress.XtraGrid;
using DevExpress.XtraGrid.Views.Base;
using DevExpress.XtraGrid.Registrator;
using DevExpress.XtraGrid.Views.Base.ViewInfo;
using DevExpress.XtraGrid.Views.Base.Handler;
using DevExpress.XtraGrid.Views.Grid.ViewInfo;
using DevExpress.XtraGrid.Views.Grid;
using System;
using DevExpress.Data.Filtering;
using DevExpress.XtraGrid.Columns;

namespace WinFormsApp2
{
    [ToolboxItem(true)]
    public partial class GridControl : DevExpress.XtraGrid.GridControl
    {
        public GridControl()
        {
            this.UseEmbeddedNavigator = false;
        }
        protected override BaseView CreateDefaultView()
        {
            var view = CreateView("gridView");
            return view;
        }
        protected override void RegisterAvailableViewsCore(InfoCollection collection)
        {
            base.RegisterAvailableViewsCore(collection);
            collection.Add(new GridViewLaptrinhVBInfoRegistrator());
        }

        public class GridLaptrinhVBHandler : DevExpress.XtraGrid.Views.Grid.Handler.GridHandler
        {
            public GridLaptrinhVBHandler(GridView gridView) : base(gridView) { }

            protected override void OnKeyDown(KeyEventArgs e)
            {
                base.OnKeyDown(e);
                if (e.KeyData == Keys.Delete && View.State == GridState.Normal)
                    View.DeleteRow(View.FocusedRowHandle);
            }
        }

        public class GridViewLaptrinhVBInfoRegistrator : GridInfoRegistrator
        {
            public override string ViewName { get { return "gridView"; } }
            public override BaseView CreateView(DevExpress.XtraGrid.GridControl grid) { return new GridViewLaptrinhVB(grid as DevExpress.XtraGrid.GridControl); }
            public override BaseViewInfo CreateViewInfo(BaseView view) { return new GridViewLaptrinhVBInfo(view as GridViewLaptrinhVB); }
            public override BaseViewHandler CreateHandler(BaseView view) { return new GridLaptrinhVBHandler(view as GridViewLaptrinhVB); }
        }

        public class GridViewLaptrinhVB : DevExpress.XtraGrid.Views.Grid.GridView
        {
            private int hotTrackRow = DevExpress.XtraGrid.GridControl.InvalidRowHandle;
            private int HotTrackRow
            {
                get
                {
                    return hotTrackRow;
                }
                set
                {
                    if (hotTrackRow != value)
                    {
                        int prevHotTrackRow = hotTrackRow;
                        hotTrackRow = value;
                        this.RefreshRow(prevHotTrackRow);
                        this.RefreshRow(hotTrackRow);
                    }
                }
            }
            public GridViewLaptrinhVB()
                : this(null)
            {
            }
            public GridViewLaptrinhVB(DevExpress.XtraGrid.GridControl grid)
                : base(grid)
            {
                //this.OptionsBehavior.AllowAddRows = DevExpress.Utils.DefaultBoolean.True;
                //this.OptionsSelection.MultiSelect = true;
                //this.OptionsSelection.MultiSelectMode = DevExpress.XtraGrid.Views.Grid.GridMultiSelectMode.CheckBoxRowSelect;
                //this.OptionsSelection.ShowCheckBoxSelectorInColumnHeader = DevExpress.Utils.DefaultBoolean.True;
                //this.OptionsView.ShowAutoFilterRow = true;
                this.OptionsView.ShowGroupPanel = false;
                //this.OptionsBehavior.AutoExpandAllGroups = true;
                //this.OptionsView.ColumnAutoWidth = false;
                this.OptionsSelection.CheckBoxSelectorColumnWidth = 30;
                this.Appearance.EvenRow.BackColor = Color.FromArgb(192, 255, 192);// 224, 224, 224);
                this.OptionsView.EnableAppearanceEvenRow = true;

                //this.MouseWheel += GridViewLaptrinhVB_MouseWheel;
                //this.MouseMove += GridViewLaptrinhVB_MouseMove;
                this.RowCellStyle += GridViewLaptrinhVB_RowCellStyle;
                //this.DataSourceChanged += GridViewLaptrinhVB_DataSourceChanged;
                this.CustomDrawRowIndicator += Gridview_CustomDrawRowIndicator;
                this.IndicatorWidth = 50;
                //this.CustomDrawCell += GridView_CustomDrawCell;
            }
            #region Custom Events
            public void Gridview_CustomDrawRowIndicator(object sender, RowIndicatorCustomDrawEventArgs e)
            {

                if (e.RowHandle >= 0)
                    e.Info.DisplayText = (e.RowHandle + 1).ToString();
            }

            private void GridViewLaptrinhVB_DataSourceChanged(object sender, EventArgs e)
            {
                (sender as GridView).BestFitColumns();
            }
            public static void GridViewLaptrinhVB_MouseWheel(object sender, MouseEventArgs e)
            {
                if (sender != null && ((GridView)sender).IsEditing)
                {
                    ((GridView)sender).CloseEditor();
                    ((GridView)sender).UpdateCurrentRow();
                }
            }
            void GridViewLaptrinhVB_MouseMove(object sender, MouseEventArgs e)
            {
                GridView view = sender as GridView;
                GridHitInfo info = view.CalcHitInfo(new Point(e.X, e.Y));

                if (info.InRowCell)
                    HotTrackRow = info.RowHandle;
                else
                    HotTrackRow = DevExpress.XtraGrid.GridControl.InvalidRowHandle;

            }

            void GridView_CustomDrawCell(object sender, RowCellCustomDrawEventArgs e)
            {
                if (hotTrackRow != e.RowHandle && e.RowHandle != this.FocusedRowHandle) return;
                GridCellInfo CellInfo = e.Cell as GridCellInfo;

                SimpleButton button = new SimpleButton();
                this.GridControl.FindForm().Controls.Add(button);
                button.Bounds = CellInfo.RowInfo.Bounds;

                Bitmap bm = new Bitmap(button.Width, button.Height);
                button.DrawToBitmap(bm, new Rectangle(0, 0, bm.Width, bm.Height));
                Rectangle rec = Rectangle.Intersect(CellInfo.RowInfo.Bounds, CellInfo.CellValueRect);
                rec.Offset(-CellInfo.RowInfo.Bounds.X, -CellInfo.RowInfo.Bounds.Y);
                e.Cache.Paint.DrawImage(e.Cache.Graphics, bm, CellInfo.Bounds);
                this.GridControl.FindForm().Controls.Remove(button);
            }

            private void GridViewLaptrinhVB_RowCellStyle(object sender, DevExpress.XtraGrid.Views.Grid.RowCellStyleEventArgs e)
            {
                if (e.RowHandle == hotTrackRow)
                    e.Appearance.BackColor = Color.FromArgb(192, 255, 192);// 192, 255, 255);//Color.PaleGoldenrod;
            }
            #endregion

            protected override string ViewName
            {
                get
                {
                    return "gridView";
                }
            }
            protected override bool AllowFixedCheckboxSelectorColumn
            {
                get
                {
                    return true;
                }
            }
            protected override void CreateCheckboxSelectorColumn()
            {
                base.CreateCheckboxSelectorColumn();
                CheckboxSelectorColumn.Fixed = DevExpress.XtraGrid.Columns.FixedStyle.Left;
            }
        }
        public class GridViewLaptrinhVBInfo : GridViewInfo
        {
            public GridViewLaptrinhVBInfo(DevExpress.XtraGrid.Views.Grid.GridView gridView) : base(gridView) { }

            public override int MinRowHeight
            {
                get
                {
                    return base.MinRowHeight - 2;
                }
            }

            public override bool UpdateFixedColumnInfo()
            {
                return base.UpdateFixedColumnInfo();
            }
        }
    }
}
