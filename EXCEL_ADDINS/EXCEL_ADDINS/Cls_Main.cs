using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    class Cls_Main
    {
        public string err_Main = string.Empty;
        public bool ConnectDataBase()
        {
            bool connects = true;
            try
            {
                if (Program.gcnConnect.State == ConnectionState.Open)
                    Program.gcnConnect.Close();
                Program.gcnConnect.ConnectionString = Program.gsConnectionString;
                Program.gcnConnect.Open();
                connects = true;
            }
            catch (Exception ex)
            {
                //MessageBox.Show("Lỗi: "+ex.Message);
                err_Main = ex.Message;
                connects = false;
                //if (err_Main != null)
                //{
                //    err_Main("Không vào được server.");
                //}
            }
            return connects;
        }
    }
}
