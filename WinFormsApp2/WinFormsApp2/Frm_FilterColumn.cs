using DevExpress.Utils;
using DevExpress.XtraEditors;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WinFormsApp2
{
    public partial class Frm_FilterColumn : XtraForm//Form
    {
        public static DataTable dt_Filter = new DataTable();
        public static int _no_select = 0;
        public static string _status_selected = "";
        public Frm_FilterColumn()
        {
            InitializeComponent();
            load_Grid_Filter_WF("");
            this.StartPosition = FormStartPosition.CenterScreen;
        }
        void load_Grid_Filter_WF(string _listcolumn)
        {
            //get detail
            ArrayList array_p1 = new ArrayList()
            {
                "@Division",
                "@FM_KEY"
            };
            ArrayList array_v1 = new ArrayList()
            {
                Connection_SQL._division,
                Connection_SQL._fmkey
            };
            _status_selected = "Load_data";
            //dt_Filter = new DataTable();
            dt_Filter = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_Filter_WF", array_p1, array_v1);
            gridControl1.DataSource = dt_Filter;
            gridControl1.ForceInitialize();
            gridView1.OptionsBehavior.Editable = false;
            gridView1.OptionsBehavior.ReadOnly = true;
            gridView1.OptionsBehavior.EditingMode = DevExpress.XtraGrid.Views.Grid.GridEditingMode.Inplace;
            gridView1.OptionsBehavior.EditorShowMode = EditorShowMode.MouseDownFocused;//EditorShowMode.MouseDownFocused;

            
            for (int i = 0; i < gridView1.RowCount; i++)
            {
                if (gridView1.GetRowCellValue(i, "Allow_Show").ToString() == "1")
                {
                    gridView1.SelectRow(i);
                }
                else
                {
                    _no_select += 1;
                }
            }
            if (_no_select > 0)
            {
                chkSelectedAll.Checked = false;
            }
            else
            {
                chkSelectedAll.Checked = true;
            }
            _status_selected = "";
        }

        private void cmdApply_Click(object sender, EventArgs e)
        {
            //ArrayList rows = new ArrayList();  // Add the selected rows to the list.  
            Int32[] selectedRowHandles = gridView1.GetSelectedRows();
            string _list_column = "";
            for (int i = 0; i < selectedRowHandles.Length; i++)
            {
                int selectedRowHandle = selectedRowHandles[i];

                if (selectedRowHandle >= 0)
                {
                    if (_list_column.Length == 0)
                    {
                        _list_column = gridView1.GetRowCellValue(selectedRowHandle, "List Group Column").ToString();
                    }
                    else
                    {
                        _list_column = _list_column + "," + gridView1.GetRowCellValue(selectedRowHandle, "List Group Column").ToString();
                    }
                }
                //rows.Add(gridView1.GetDataRow(selectedRowHandle)); // Over here the GetDataRow returns Null  
            }
            if (_list_column.Length == 0)
            {
                if (_list_column.Length==0)
                {
                    MessageBox.Show("Bạn chưa chọn bất kỳ cột nào", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            else
            {
                New_sp nw = new New_sp();
                nw.sp_Update_Filter_WF
                (
                    Connection_SQL._division,
                    Connection_SQL._fmkey,
                   _list_column
                );
                if (nw.b_success == "1")
                {
                    
                }
                else
                {
                    MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            //refresh ALl wf
            //Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
            this.Close();
            //MessageBox.Show(_list_column);
        }

        private void Frm_FilterColumn_Load(object sender, EventArgs e)
        {

        }

        private void chkSelectedAll_CheckedChanged(object sender, EventArgs e)
        {
            if (_status_selected != "Load_data")
            {
                if (chkSelectedAll.Checked == true)
                {
                    for (int i = 0; i < gridView1.RowCount; i++)
                    {
                        gridView1.SelectRow(i);
                    }
                }
                else
                {
                    for (int i = 0; i < gridView1.RowCount; i++)
                    {
                        gridView1.UnselectRow(i);
                    }
                }
            }
        }
    }
}
