using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public partial class FrmFilter : Form
    {
        public static DataTable dt_filter = null;
        private int desiredStartLocationX;
        private int desiredStartLocationY;
        public static bool _loading = false;
        public FrmFilter()
        {
            InitializeComponent();
            dataGridView1.GetType().GetProperty("DoubleBuffered", BindingFlags.Instance | BindingFlags.NonPublic).SetValue(dataGridView1, true, null);
            create_tootips();
            //DataTable dt = new DataTable();
            //_sp_name = "sp_Get_SellIn";
            ArrayList array_param = new ArrayList() { "@Division","@FM_KEY" };
            ArrayList array_value = new ArrayList() { Connection_SQL._division,Connection_SQL._fmkey };

            dt_filter = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_Filter_WF", array_param, array_value);
            dataGridView1.DataSource = dt_filter;
            dataGridView1.Columns[0].Width=200;
            dataGridView1.Columns[1].Visible = false;
            dataGridView1.Columns[2].Visible = false;
            dataGridView1.AllowUserToAddRows = false;
            
            
        }
        void create_tootips()
        {
            // Create the ToolTip and associate with the Form container.
            ToolTip toolTip1 = new ToolTip();

            // Set up the delays for the ToolTip.
            toolTip1.AutoPopDelay = 5000;
            toolTip1.InitialDelay = 1000;
            toolTip1.ReshowDelay = 500;
            // Force the ToolTip text to be displayed whether or not the form is active.
            toolTip1.ShowAlways = true;

            // Set up the ToolTip text for the Button and Checkbox.
            toolTip1.SetToolTip(this.cmdApply, "Nhấn Apply sẽ reload lại data \n đồng thời refresh lại filter hoàn toàn");
        }
        public FrmFilter(int x, int y) : this()
        {
            this.desiredStartLocationX = x;
            this.desiredStartLocationY = y;

            Load += new EventHandler(FrmFilter_Load);
        }

        private void FrmFilter_Load(object sender, EventArgs e)
        {
            _loading = true;
            int _countselected = 0;
            this.SetDesktopLocation(desiredStartLocationX, desiredStartLocationY);
            for (int i = 0; i < dataGridView1.RowCount; i++)
            {
                if (dataGridView1.Rows[i].Cells[2].Value.ToString() == "1")
                {
                    _countselected = _countselected + 1;
                    dataGridView1.Rows[i].Cells[0].Selected = true;
                }
            }
            if (_countselected == dataGridView1.RowCount)
            {
                chkSelectAll.Checked = true;
            }
            else
            {
                chkSelectAll.Checked = false;
            }
            _loading = false;
        }

        private void cmdApply_Click(object sender, EventArgs e)
        {
            try
            {
                Int32 selectedCellCount = dataGridView1.GetCellCount(DataGridViewElementStates.Selected);
                //MessageBox.Show(selectedCellCount.ToString());
                if (selectedCellCount > 0)
                {
                    //if (dataGridView1.AreAllCellsSelected(true))
                    //{
                    //    MessageBox.Show("All cells are selected", "Selected Cells");
                    //}
                    //else
                    //{
                    //    System.Text.StringBuilder sb = new System.Text.StringBuilder();

                    //    for (int i = 0;i < dataGridView1.Rows.Count; i++)
                    //    {
                    //        if (dataGridView1.Rows[i].Cells[0].Selected)
                    //        {
                    //            sb.Append("Row: ");
                    //            sb.Append(dataGridView1.Rows[i].Cells[0].Value.ToString());
                    //            sb.Append(Environment.NewLine);
                    //        }
                    //        //sb.Append("Row: ");
                    //        //sb.Append(dataGridView1.SelectedCells[i].RowIndex.ToString());
                    //        ////sb.Append(", Column: ");
                    //        ////sb.Append(dataGridView1.SelectedCells[i].ColumnIndex
                    //        ////    .ToString());
                    //        //sb.Append(Environment.NewLine);
                    //    }

                    //    //sb.Append("Total: " + selectedCellCount.ToString());
                    //    MessageBox.Show(sb.ToString(), "Selected Cells");
                    //}
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();
                    string _listColumn = string.Empty;

                    for (int i = 0; i < dataGridView1.Rows.Count; i++)
                    {
                        if (dataGridView1.Rows[i].Cells[0].Selected)
                        {
                            if (_listColumn.Length == 0)
                            {
                                _listColumn = dataGridView1.Rows[i].Cells[0].Value.ToString();
                            }
                            else
                            {
                                _listColumn = _listColumn + "," + dataGridView1.Rows[i].Cells[0].Value.ToString();
                            }
                            //sb.Append("Row: ");
                            //sb.Append(dataGridView1.Rows[i].Cells[0].Value.ToString());
                            //sb.Append(Environment.NewLine);
                        }
                        //sb.Append("Row: ");
                        //sb.Append(dataGridView1.SelectedCells[i].RowIndex.ToString());
                        ////sb.Append(", Column: ");
                        ////sb.Append(dataGridView1.SelectedCells[i].ColumnIndex
                        ////    .ToString());
                        //sb.Append(Environment.NewLine);
                    }
                    if (_listColumn.Length > 0)
                    {
                        New_sp nw = new New_sp();
                        nw.sp_Update_Filter_WF
                        (
                            Connection_SQL._division,
                            Connection_SQL._fmkey,
                            _listColumn
                        );
                        if (nw.b_success == "1")
                        {
                            this.Close();
                            //filter_config
                            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("filter_config");
                            //refresh ALl wf
                            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
                        }
                        else
                        {
                            MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                    //sb.Append("Total: " + selectedCellCount.ToString());
                    //MessageBox.Show(sb.ToString(), "Selected Cells");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //dataGridView1.SelectedRows[e.RowIndex].Selected = true;
        }

        private void chkSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            if (_loading==false)
            {
                if (chkSelectAll.Checked)
                {
                    dataGridView1.SelectAll();
                }
                else
                {
                    dataGridView1.ClearSelection();
                }
            }
        }
    }
}
