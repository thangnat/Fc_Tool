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
    public partial class FrmInputMessage : Form
    {
        public static string _promt = string.Empty;
        public static string _folder_path = string.Empty;
        public static string _title = "Loreal VN";
        public FrmInputMessage(string promt_, string folder_path_)
        {
            InitializeComponent();
            _promt = promt_;
            _folder_path = folder_path_;
            this.StartPosition = FormStartPosition.CenterScreen;
            lbMessage.Text = _promt;
            txtinfo.Text = _folder_path;
        }

        private void FrmInputMessage_Load(object sender, EventArgs e)
        {

        }
    }
}
