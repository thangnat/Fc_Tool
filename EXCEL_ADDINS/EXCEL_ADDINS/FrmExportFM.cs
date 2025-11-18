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
    public partial class FrmExportFM : Form
    {
        public static string _sp_name = "sp_FC_EXPORT_TO_FM";

        public string _division = string.Empty;
        public string _fmkey = string.Empty;
        public FrmExportFM()
        {
            InitializeComponent();
            _division = Connection_SQL._division.Trim();
            _fmkey = Connection_SQL._fmkey.Trim().Replace("-", "");

            DataTable dt = new DataTable();
            //_sp_name = "sp_Get_SellIn";
            ArrayList array_param = new ArrayList() { "@Division", "@FMKEY"};
            ArrayList array_value = new ArrayList() { _division, _fmkey};

            dt = Connection_SQL.Exec_StoreProc_datatable_Admin(_sp_name, array_param, array_value);
            dataGridView1.DataSource = dt;
            dataGridView1.Columns[4].Width = 300;
        }

        private void FrmExportFM_Load(object sender, EventArgs e)
        {
           
        }
    }
}
