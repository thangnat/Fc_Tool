using System;
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
    public partial class frm_PeriodKey : Form
    {
        public frm_PeriodKey()
        {
            InitializeComponent();
        }

        private void cmdRun_Click(object sender, EventArgs e)
        {
            try
            {
                New_sp nw = new New_sp();
                nw.sp_Run_SO_HIS_FINAL
                (
                    Connection_SQL._division,
                    txtPeriodKey.Text
                );
                if (nw.b_success == "1")
                {
                    MessageBox.Show("Import SISOSIT Data successfully.../", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void frm_PeriodKey_Load(object sender, EventArgs e)
        {
            txtPeriodKey.Text = Connection_SQL._fmkey;// DateTime.Now.AddMonths(-1).ToString("yyyyMM");
        }

        private void groupBox1_Enter(object sender, EventArgs e)
        {

        }
    }
}
