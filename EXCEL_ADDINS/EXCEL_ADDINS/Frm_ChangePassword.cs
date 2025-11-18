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
    public partial class Frm_ChangePassword : Form
    {
        public Frm_ChangePassword()
        {
            InitializeComponent();
        }

        private void CmdCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void CmdSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                DialogResult drl = MessageBox.Show("Do you want to change your password?", "Loreal VN", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (drl == DialogResult.Yes)
                {
                    New_sp nw = new New_sp();
                    nw.sp_change_password_Login
                    (
                        txtUserName.Text,
                        txtPassword.Text,
                        txtrePassword.Text
                    );
                    if (nw.b_success == "1")
                    {
                        MessageBox.Show("Change Password successfully.../", "Loreal VN", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    else
                    {
                        MessageBox.Show(nw.c_errmsg, "Loreal VN", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
            catch(Exception ex)
            {
                MessageBox.Show(ex.Message, "Loreal VN", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
    }
}
