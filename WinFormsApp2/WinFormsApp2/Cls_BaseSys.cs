using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WinFormsApp2
{
    public class Cls_BaseSys
    {
        #region Property
        public int MaPB
        {
            get
            {
                return mod_BaseSys.gnMaPB;
            }
            set
            {
                mod_BaseSys.gnMaPB = value;
            }
        }
        // public static string gsCompanyCode;
        public string gsCompanyCode
        {
            get
            {
                return mod_BaseSys.gsCompanyCode;
            }
            set
            {
                mod_BaseSys.gsCompanyCode = value;
            }
        }
        public string UserID
        {
            get
            {
                return mod_BaseSys.gsUserID;
            }
            set
            {
                mod_BaseSys.gsUserID = value;
            }
        }
        public string GTime
        {
            get
            {
                return mod_BaseSys.gsTime;
            }
            set
            {
                mod_BaseSys.gsTime = value;
            }
        }
        public string GDate
        {
            get
            {
                return mod_BaseSys.gsDate;
            }
            set
            {
                mod_BaseSys.gsDate = value;
            }
        }
        public string ApplicationPath
        {
            get
            {
                return mod_BaseSys.gsApplicationPath;
            }
            set
            {
                mod_BaseSys.gsApplicationPath = value;
            }
        }
        public string SourcePath
        {
            get
            {
                return mod_BaseSys.gsSourcePath;
            }
            set
            {
                mod_BaseSys.gsSourcePath = value;
            }
        }
        public string UserName
        {
            get
            {
                return mod_BaseSys.gsUserName;
            }
            set
            {
                mod_BaseSys.gsUserName = value;
            }
        }
        public string Account
        {
            get
            {
                return mod_BaseSys.gsAccount;
            }
            set
            {
                mod_BaseSys.gsAccount = value;
            }
        }
        public SqlConnection CnConnect
        {
            get
            {
                return mod_BaseSys.gcnConnect;
            }
            set
            {
                mod_BaseSys.gcnConnect = value;
            }
        }
        public int PhanHanh
        {
            get
            {
                return mod_BaseSys.gnPhanHanh;
            }
            set
            {
                mod_BaseSys.gnPhanHanh = value;
            }
        }
        public string Right
        {
            get
            {
                return mod_BaseSys.gsRight;
            }
            set
            {
                mod_BaseSys.gsRight = value;
            }
        }
        public string SanPhamPath
        {
            get
            {
                return mod_BaseSys.gsSanPhamPath;
            }
            set
            {
                mod_BaseSys.gsSanPhamPath = value;
            }
        }
        public string ConnectionString
        {
            get
            {
                return mod_BaseSys.gsConnectionString;
            }
            set
            {
                mod_BaseSys.gsConnectionString = value;
            }
        }
        public string ApplicationName
        {
            get
            {
                return mod_BaseSys.gsApplicationName;
            }
            set
            {
                mod_BaseSys.gsApplicationName = value;
            }
        }
        public static string Division
        {
            get
            {
                return mod_BaseSys.gsDivision;
            }
            set
            {
                mod_BaseSys.gsDivision = value;
            }
        }
        public string Computername
        {
            get
            {
                return mod_BaseSys.gsComputername;
            }
            set
            {
                mod_BaseSys.gsComputername = value;
            }
        }
        public string ToolName
        {
            get
            {
                return mod_BaseSys.gsToolName;
            }
            set
            {
                mod_BaseSys.gsToolName = value;
            }
        }
        public string FMKEY
        {
            get
            {
                return mod_BaseSys.gsFMKEY;
            }
            set
            {
                mod_BaseSys.gsFMKEY = value;
            }
        }
        //public DataTable _dt_nameList = null;
        #endregion
        public bool CheckExistData(string sSql)
        {
            SqlDataAdapter daAdapter = new SqlDataAdapter();
            SqlCommand cmCommand = new SqlCommand();
            DataSet dsDataset = new DataSet();
            try
            {
                cmCommand.CommandText = sSql;
                cmCommand.CommandType = CommandType.Text;
                cmCommand.Connection = mod_BaseSys.gcnConnect;
                cmCommand.CommandTimeout = 0;
                daAdapter.SelectCommand = cmCommand;
                daAdapter.Fill(dsDataset);
                if (dsDataset.Tables[0].Rows.Count > 0 && this.IsEmpty(dsDataset) == false)
                {
                    return true;
                }
            }
            catch (Exception)
            {
                MessageBox.Show("Lỗi hàm lấy dữ liệu!");
                //RaiseEvent err_ChietTinh("KhÃ´ng thá»±c hiá»‡n Ä‘Æ°á»£c.")
            }
            return false;
        }
        public bool IsEmpty(DataSet dataSet)
        {
            foreach (DataTable table in dataSet.Tables)
                if (table.Rows.Count != 0)
                    return false;
            return true;
        }
        public bool ContainColumn(string columnName, DataTable table)
        {
            DataColumnCollection columns = table.Columns;
            if (columns.Contains(columnName))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        //public DataTable GetDataTable_Admin(string sSql)
        //{
        //    Program.gcnConnect_admin.ConnectionString = Program.gsConnectionString_admin;
        //    SqlDataAdapter daAdapter = new SqlDataAdapter();
        //    SqlCommand cmCommand = new SqlCommand();
        //    DataTable dt = new DataTable();
        //    try
        //    {
        //        cmCommand.CommandText = sSql;
        //        cmCommand.CommandType = CommandType.Text;
        //        cmCommand.Connection = Program.gcnConnect_admin;
        //        cmCommand.CommandTimeout = 0;
        //        daAdapter.SelectCommand = cmCommand;
        //        daAdapter.Fill(dt);
        //    }
        //    catch (Exception)
        //    {
        //        MessageBox.Show("Lỗi hàm lấy dữ liệu!");
        //        //RaiseEvent err_ChietTinh("KhÃ´ng thá»±c hiá»‡n Ä‘Æ°á»£c.")
        //    }
        //    return dt;
        //}
        public DataTable GetDataTable(string sSql)
        {
            SqlDataAdapter daAdapter = new SqlDataAdapter();
            SqlCommand cmCommand = new SqlCommand();
            DataTable dt = new DataTable();
            try
            {
                cmCommand.CommandText = sSql;
                cmCommand.CommandType = CommandType.Text;
                cmCommand.Connection = mod_BaseSys.gcnConnect;
                cmCommand.CommandTimeout = 0;
                daAdapter.SelectCommand = cmCommand;
                daAdapter.Fill(dt);
            }
            catch (Exception)
            {
                MessageBox.Show("Lỗi hàm lấy dữ liệu!");
                //RaiseEvent err_ChietTinh("KhÃ´ng thá»±c hiá»‡n Ä‘Æ°á»£c.")
            }
            return dt;
        }
        public DataTable Exec_StoreProc_datatable(string sStoreProc, ArrayList _parasName, ArrayList _parasValue)
        {
            string sSql = null;
            SqlTransaction Trans = null;
            DataTable dt = new DataTable();
            try
            {
                if (mod_BaseSys.gcnConnect == null)
                {
                    return dt;
                }
                else
                {
                    if (mod_BaseSys.gcnConnect.State == ConnectionState.Closed)
                    {
                        mod_BaseSys.gcnConnect.Open();
                    }
                    SqlCommand cmd = new SqlCommand();
                    SqlDataAdapter da = new SqlDataAdapter();
                    cmd.Connection = mod_BaseSys.gcnConnect;
                    cmd.CommandTimeout = 0;
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = sStoreProc;
                    sSql = cmd.CommandText + " ";
                    int i;
                    for (i = 0; i <= _parasValue.Count - 1; i++)
                    {
                        cmd.Parameters.Add(Convert.ToString(_parasName[i]), SqlDbType.NVarChar).Value = _parasValue[i];

                        sSql = sSql + _parasValue[i] + ",";
                    }
                    if (i > 0)
                    {
                        sSql = sSql.Substring(0, sSql.Length - 1);
                    }

                    //if (sStoreProc == "sp_rpt_PackinglistStandard")
                    //{
                    //    sSql = "sp_rpt_PackinglistStandard_test 6900021863,''";
                    //}
                    Trans = mod_BaseSys.gcnConnect.BeginTransaction();
                    cmd.Transaction = Trans;
                    da.SelectCommand = cmd;
                    //SqlDependency de = new SqlDependency(cmd);
                    //de.OnChange += new OnChangeEventHandler(de_OnChange);
                    da.Fill(dt);
                    //dt.Load(cmd.ExecuteReader(CommandBehavior.CloseConnection));
                    //cmd.ExecuteNonQuery();
                    Trans.Commit();
                    return dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi!" + ex.Message);
                Trans.Rollback();
                return dt;
                //return false;
            }
        }
        //public DataTable Exec_StoreProc_datatable_Admin(string sStoreProc, ArrayList _parasName, ArrayList _parasValue)
        //{
        //    Program.gcnConnect_admin.ConnectionString = Program.gsConnectionString_admin;
        //    string sSql = null;
        //    SqlTransaction Trans = null;
        //    DataTable dt = new DataTable();
        //    try
        //    {
        //        if (Program.gcnConnect_admin == null)
        //        {
        //            return dt;
        //        }
        //        else
        //        {
        //            if (Program.gcnConnect_admin.State == ConnectionState.Closed)
        //            {
        //                Program.gcnConnect_admin.Open();
        //            }
        //            SqlCommand cmd = new SqlCommand();
        //            SqlDataAdapter da = new SqlDataAdapter();
        //            cmd.Connection = Program.gcnConnect_admin;// mod_BaseSys.gcnConnect;
        //            cmd.CommandTimeout = 0;
        //            cmd.CommandType = CommandType.StoredProcedure;
        //            cmd.CommandText = sStoreProc;
        //            sSql = cmd.CommandText + " ";
        //            int i;
        //            for (i = 0; i <= _parasValue.Count - 1; i++)
        //            {
        //                cmd.Parameters.Add(Convert.ToString(_parasName[i]), SqlDbType.NVarChar).Value = _parasValue[i];

        //                sSql = sSql + _parasValue[i] + ",";
        //            }
        //            if (i > 0)
        //            {
        //                sSql = sSql.Substring(0, sSql.Length - 1);
        //            }

        //            //if (sStoreProc == "sp_rpt_PackinglistStandard")
        //            //{
        //            //    sSql = "sp_rpt_PackinglistStandard_test 6900021863,''";
        //            //}
        //            Trans = Program.gcnConnect_admin.BeginTransaction();
        //            cmd.Transaction = Trans;
        //            da.SelectCommand = cmd;
        //            //SqlDependency de = new SqlDependency(cmd);
        //            //de.OnChange += new OnChangeEventHandler(de_OnChange);
        //            da.Fill(dt);
        //            //dt.Load(cmd.ExecuteReader(CommandBehavior.CloseConnection));
        //            //cmd.ExecuteNonQuery();
        //            Trans.Commit();
        //            return dt;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show("Lỗi!" + ex.Message);
        //        Trans.Rollback();
        //        return dt;
        //        //return false;
        //    }
        //}
    }
}
