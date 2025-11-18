using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using DevExpress.XtraEditors;

namespace WinFormsApp2
{
    public partial class Frm_MM_master : XtraForm
    {
        public Frm_MM_master()
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterScreen;
        }

        private void CmdLoadData_Click(object sender, EventArgs e)
        {
            gridControl1.DataSource = Connection_SQL.GetDataTable(@"select * from fnc_SubGroupMaster_Full_CPD where FM_KEY='202409'");
            gridControl1.ForceInitialize();
            gridView1.OptionsView.ColumnAutoWidth = false;
            gridView1.BestFitColumns();
        }

        private void Frm_MM_master_Load(object sender, EventArgs e)
        {
            
        }
    }
}
