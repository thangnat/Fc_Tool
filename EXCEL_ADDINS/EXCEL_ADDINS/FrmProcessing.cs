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
    public partial class FrmProcessing : Form
    {
        public FrmProcessing()
        {
            InitializeComponent();
            //System.Threading.Thread.Sleep(1000);
        }
        bool Check_user_action()
        {
            bool _action = false;
            DataTable dt_user_info = new DataTable();
            //MessageBox.Show(Connection_SQL._userID);
            dt_user_info = Connection_SQL.GetDataTable(@"select [Action] from V_FC_CONFIG_USER_ALLOW where Division='" 
                        + Connection_SQL._division + "' and active = 1 and userid = '" + Connection_SQL._userID + "'");

            if (dt_user_info.Rows.Count == 0)
            {
                _action = false;
            }
            else
            {
                string _action_status = "";
                _action_status = dt_user_info.Rows[0]["Action"].ToString();
                if (_action_status == "0")
                {
                    _action = false;
                }
                else
                {
                    _action = true;
                }
            }
            return _action;
        }
        //void save()
        //{
        //    System.Threading.Thread.Sleep(3000);
        //    //grpProcessing.Visible = true;
        //    if (Check_user_action())
        //    {
        //        //string _starttime = "start time:" + DateTime.Now.ToString();
        //        //lbtime.Text = "";
        //        //lbtime.Text = lbtime.Text + "," + "start update fc: " + DateTime.Now.ToString();
        //        string _type_refresh_ = "fc";
        //        cls_function.Save_Only_FC(_type_refresh_);
        //        //lbtime.Text = lbtime.Text + "," + "done update fc: " + DateTime.Now.ToString();
        //        New_sp nw = new New_sp();
        //        nw.sp_calculate_total
        //        (
        //            Connection_SQL._division,
        //            Connection_SQL._fmkey,
        //            "fc"
        //        );
        //        //lbtime.Text = lbtime.Text + "," + "done calculation fc: " + DateTime.Now.ToString();
        //        if (nw.b_success == "1")
        //        {
        //            //New_sp nw1 = new New_sp();
        //            //nw1.sp_Check_GAP_NEW
        //            //(
        //            //    Connection_SQL._division,
        //            //    Connection_SQL._fmkey
        //            //);
        //            //if (nw1.b_success == "1")
        //            //{
        //            if (_type_refresh_.ToUpper() == "ALL")
        //            {
        //                //refresh ALl wf
        //                Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_All");
        //            }
        //            else
        //            {
        //                //refresh fc column only
        //                cls_function.refresh_WF_Question(false);
        //            }
        //            //}
        //            //else
        //            //{
        //            //    MessageBox.Show(nw1.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //            //}
        //            //lbtime.Text = lbtime.Text + "," + "done loading data: " + DateTime.Now.ToString();
        //            //}
        //            //grpProcessing.Visible = false;
        //        }
        //        else
        //        {
        //            MessageBox.Show(nw.c_errmsg, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        }
        //        //rShowAllWF.Checked = false;
        //    }
        //    else
        //    {
        //        MessageBox.Show("user not permission", "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
        //    }
        //    //grpProcessing.Visible = false;
        //    this.Close();
        //}
        private void FrmProcessing_Load(object sender, EventArgs e)
        {
            
            button1.PerformClick();
        }

        //private void button1_Click(object sender, EventArgs e)
        //{
        //    save();
        //}
    }
}
