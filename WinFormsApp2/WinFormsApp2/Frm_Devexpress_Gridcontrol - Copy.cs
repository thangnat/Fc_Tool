using DevExpress.DataProcessing;
using DevExpress.XtraEditors;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace WinFormsApp2
{
    public partial class Frm_Devexpress_Gridcontrol : Form
    {
        //conn cls_sys = new Cls_BaseSys();
        //Datat Table
        public static DataTable dt_month_list = new DataTable();
        public static DataTable dt_Signature_List = new DataTable();
        public static DataTable dt_HERO_list = new DataTable();
        public static DataTable dt_Category_list = new DataTable();
        public static DataTable dt_Sub_Category_list = new DataTable();
        public static DataTable dt_Group_Class_list = new DataTable();

        public static bool _select_All = false;

        public Frm_Devexpress_Gridcontrol(string _division,string _fm_key)
        {
            InitializeComponent();

            //create month list
            Create_Month_List_Ini(_select_All);
            //push month list into datagridview
            get_Motnh_Datagridview();
            //get master data from WF   
            Create_Master_Data_WF();
            //push dataatble tinto control gridlookupedit
            push_master_Into_Control();
        }
        void Create_Master_Data_WF()
        {
            dt_Signature_List = Connection_SQL.GetDataTable(@"select DISTINCT [Signature] from FC_FM_Original_"+Connection_SQL._division+ " where isnull([Signature],'')<>'' ");
            dt_HERO_list = Connection_SQL.GetDataTable(@"select DISTINCT HERO from FC_FM_Original_" + Connection_SQL._division+ " where isnull(HERO,'')<>'' ");
            dt_Category_list = Connection_SQL.GetDataTable(@"select DISTINCT [CAT/Axe] from FC_FM_Original_" + Connection_SQL._division+" where isnull([CAT/Axe],'')<>''");
            dt_Sub_Category_list = Connection_SQL.GetDataTable(@"select DISTINCT [SUB CAT/ Sub Axe] from FC_FM_Original_" + Connection_SQL._division+ " where isnull([SUB CAT/ Sub Axe],'')<>'' ");
            dt_Group_Class_list = Connection_SQL.GetDataTable(@"select DISTINCT [GROUP/ Class] from FC_FM_Original_" + Connection_SQL._division+ " where isnull([GROUP/ Class],'')<>'' ");
        }
        void push_master_Into_Control()
        {
            G_Signature.DataSource = dt_Signature_List;
            G_Signature.ForceInitialize();
            G_HERO.DataSource = dt_HERO_list;
            G_HERO.ForceInitialize();
            G_Category.DataSource = dt_Category_list;
            G_Category.ForceInitialize();
            G_Sub_Category.DataSource= dt_Sub_Category_list;
            G_Sub_Category.ForceInitialize();
            G_Group_Class.DataSource= dt_Group_Class_list;
            G_Group_Class.ForceInitialize();

        }
        void get_date_employees()
        {
            DataTable dt = new DataTable();
            dt = Connection_SQL.GetDataTable(@"SELECT * FROM Employees");
            //gridControl1.DataSource = dt;
            //gridControl1.ForceInitialize();
        }
        void Create_Month_List_Ini(bool _selectAll)
        {
            dt_month_list = new DataTable();
            //define column
            dt_month_list.Columns.Add("M1", typeof(bool));
            dt_month_list.Columns.Add("M2", typeof(bool));
            dt_month_list.Columns.Add("M3", typeof(bool));
            dt_month_list.Columns.Add("M4", typeof(bool));
            dt_month_list.Columns.Add("M5", typeof(bool));
            dt_month_list.Columns.Add("M6", typeof(bool));
            dt_month_list.Columns.Add("M7", typeof(bool));
            dt_month_list.Columns.Add("M8", typeof(bool));
            dt_month_list.Columns.Add("M9", typeof(bool));
            dt_month_list.Columns.Add("M10", typeof(bool));
            dt_month_list.Columns.Add("M11", typeof(bool));
            dt_month_list.Columns.Add("M12", typeof(bool));

            //set value
            if (_selectAll==true)
            {
                dt_month_list.Rows.Add(true, true, true, true, true, true, true, true, true, true, true, true);
            }
            else
            {
                dt_month_list.Rows.Add(false, false, false, false, false, false, false, false, false, false, false, false);
            }
        }
        void get_Motnh_Datagridview()
        {
            dataGridView1.DataSource = dt_month_list;
            dataGridView1.AllowUserToAddRows = false;
            dataGridView1.Columns[0].Width = 40;
            dataGridView1.Columns[1].Width = 40;
            dataGridView1.Columns[2].Width = 40;
            dataGridView1.Columns[3].Width = 40;
            dataGridView1.Columns[4].Width = 40;
            dataGridView1.Columns[5].Width = 40;
            dataGridView1.Columns[6].Width = 40;
            dataGridView1.Columns[7].Width = 40;
            dataGridView1.Columns[8].Width = 40;
            dataGridView1.Columns[9].Width = 40;
            dataGridView1.Columns[10].Width = 40;
            dataGridView1.Columns[11].Width = 40;
        }
        private void gridControl1_Click(object sender, EventArgs e)
        {
        }
        private void Frm_Devexpress_Gridcontrol_Load(object sender, EventArgs e)
        {
            
        }
        private void cmdY0_Click(object sender, EventArgs e)
        {
            //cmdY0.Appearance.BackColor = Color.FromArgb(192, 255, 192);
            //cmdY1.Appearance.BackColor = Color.FromArgb(255, 224, 192);
        }

        private void cmdY1_Click(object sender, EventArgs e)
        {
            //cmdY1.Appearance.BackColor = Color.FromArgb(192, 255, 192);
            //cmdY0.Appearance.BackColor = Color.FromArgb(255, 224, 192);
        }

        private void cmdQ1_Click(object sender, EventArgs e)
        {
            //cmdQ1.Appearance.BackColor = Color.FromArgb(192, 255, 192);
        }

        private void chkSelectAllMonths_CheckedChanged(object sender, EventArgs e)
        {
            if (chkSelectAllMonths.Checked)
            {
                _select_All = true;
                Create_Month_List_Ini(_select_All);
                get_Motnh_Datagridview();
            }
            else
            {
                Create_Month_List_Ini(false);
                get_Motnh_Datagridview();
            }
        }
    }
}
