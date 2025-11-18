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

namespace EXCEL_ADDINS
{
    public partial class FrmComponentBom : Form
    {
        public static string _sp_name = "sp_FC_GetData_ZMR32_By_Bom";
        public string _division = string.Empty;
        public static string _bundlecode = string.Empty;
        public FrmComponentBom(string bundleCode_)
        {
            InitializeComponent();
            _division = Connection_SQL._division.Trim();
            _bundlecode = bundleCode_;
            Load_dataGrid();
        }
        void Load_dataGrid()
        {
            DataTable dt = new DataTable();
            ArrayList array_param = new ArrayList() { "@Division", "@BundleCode", "@CreateFilter" };
            ArrayList array_value = new ArrayList() { _division.Trim(), _bundlecode, 0 };

            dt = Connection_SQL.Exec_StoreProc_datatable_Admin(_sp_name, array_param, array_value);
            dataGridView1.DataSource = dt;
            dataGridView1.Columns[3].Width = 300;
            dataGridView1.AllowUserToAddRows = false;
        }
        private void FrmComponentBom_Load(object sender, EventArgs e)
        {

        }
    }
}
