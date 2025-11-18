using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public partial class FrmUpdate_Version : Form
    {
        
        
        //public string _type = string.Empty;
        public FrmUpdate_Version(string _content)
        {
            InitializeComponent();
            RichContent.Text = _content;
        }
        
        
        private void cmdImmediate_Click(object sender, EventArgs e)
        {
            //get_action("immediate");
            cls_function.Update_Version_table("IMMEDIATE");
            this.Close();
        }

        private void cmd1hour_Click(object sender, EventArgs e)
        {
            //get_action("1hour");
            cls_function.Update_Version_table("1HOUR");
            this.Close();
        }

        private void cmd2hours_Click(object sender, EventArgs e)
        {
            //get_action("2hour");
            cls_function.Update_Version_table("2HOUR");
            this.Close();
        }

        private void cmd4hours_Click(object sender, EventArgs e)
        {
            //get_action("4hour");
            cls_function.Update_Version_table("4HOUR");
            this.Close();
        }

        private void FrmUpdate_Version_FormClosed(object sender, FormClosedEventArgs e)
        {
            //this.DialogResult = DialogResult.OK;
            
        }

        private void FrmUpdate_Version_Load(object sender, EventArgs e)
        {

        }
    }
}
