using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public partial class FrmTEST : Form
    {
        public FrmTEST()
        {
            InitializeComponent();
            dataGridView1.GetType().GetProperty("DoubleBuffered", BindingFlags.Instance | BindingFlags.NonPublic).SetValue(dataGridView1, true, null);
        }

        private void cmdLoaddata_Click(object sender, EventArgs e)
        {
            string Constr = @"Data Source=.;Initial Catalog=master;User ID=sa;Password=Pd09241109@1;Connect Timeout=3600000";
            string sql = @"select * from TEST1";

            SqlConnection con = new SqlConnection(Constr);
            SqlDataAdapter dataadapter = new SqlDataAdapter(sql, con);
            DataView dataview = new DataView();
            DataSet ds = new DataSet();
            con.Open();

            dataadapter.Fill(ds);
            con.Close();

            dataview = ds.Tables[0].DefaultView;
            dataGridView1.DataSource = dataview;
            //dataGridView1.DataSource = Connection_SQL.GetDataTable(@"select * from TEST1");
        }
    }
}
