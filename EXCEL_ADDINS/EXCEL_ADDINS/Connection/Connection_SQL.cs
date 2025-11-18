using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.Windows.Forms;
using System.Collections;

namespace EXCEL_ADDINS
{
    public class Connection_SQL
    {
        //public static string Constr = "";

        public static string Constr = string.Empty;
        //Frm_Login frm = new Frm_Login();
        //public static string Constr = "Server="+ Frm_Login.Server + ";Database = "+ Frm_Login.Database +";User ID=sa;Password=Pd0924110921";
        public static SqlConnection cnn;// = new SqlConnection(Constr);
        public static SqlCommandBuilder sqlcom;
        public static SqlDataAdapter da;
        public static string ketqua_string;
        public static double ketqua_double;
        public static bool ketqua_bool;
        public static string _division = string.Empty;
        public static string _subgrp = string.Empty;
        public static string _fmkey = string.Empty;
        public static string _FC_Filename = string.Empty;
        public static string _Database_name = string.Empty;
        public static string _server_name = string.Empty;
        //public static string _FC_Filename_extention = string.Empty;
        public static string _userID = string.Empty;
        public static string _fullname = string.Empty;
        public static string _path = string.Empty;
        public static string _Seledcted_status_row_wf = string.Empty;
        public static string _default_Workbook_name = "WORKING_FILE";
        public static string _Accesspath = @"C:\Users\Public\Downloads\Application\FC\";
        public static string _Applicationpath = @"C:\Users\Public\Downloads\Application\FC\Extension\EXE_FOLDER\";
        public static string _WFpath = @"C:\Users\Public\Downloads\Application\FC\Extension\FILES\";
        public static string _version_exe = "ver1000017";
        public static DateTime _systemdatetime = DateTime.Now;

        public static void KetnoiCSDL_SQL()
        {
            try
            {
                Constr = @"Data Source="+_server_name+";Initial Catalog="+_Database_name+";User ID=" + ((_userID.Length == 0) ? "sa" : _userID) + ";Password=" + ((_userID.Length == 0) ? "Saigon@SQL2023" : "sgl789") + ";Connect Timeout=3600000";
                //Constr = @"Data Source=.;Initial Catalog=master;User ID=sa;Password=Pd09241109@1;Connect Timeout=3600000";
                //@"Data Source=10.240.65.33,1433;Initial Catalog=SC2;User ID=sa;Password=Saigon@SQL2023;Connect Timeout=3600000";
                cnn = new SqlConnection(Constr);
                bool flag = (cnn.State == ConnectionState.Closed);
                if (flag)
                {
                    cnn.Open();
                }
            }
            catch (Exception ex)
            {

                MessageBox.Show(ex.Message + "-->Connection fail...", Info._CompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        public static void Ngatketnoi_SQL()
        {
            //Constr = Frm_Login.Address_;
            cnn = new SqlConnection(Constr);
            cnn.Close();
        }

        public static string Truyvan_string(string sql)
        {
            try
            {
                KetnoiCSDL_SQL();
                SqlCommand sqlCommand = new SqlCommand(sql, cnn);

                SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
                while (sqlDataReader.Read())
                {
                    bool flag = sqlDataReader.GetString(0).Length == 0;
                    if (flag)
                    {
                        ketqua_string = "";
                    }
                    else
                    {
                        ketqua_string = sqlDataReader.GetString(0);
                    }
                }
                cnn.Close();
            }
            catch
            {
                ketqua_string = "";
            }
            return ketqua_string;
        }

        public static string Truyvan_double(string sql)
        {
            try
            {
                KetnoiCSDL_SQL();
                SqlCommand sqlCommand = new SqlCommand(sql, cnn);
                SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
                while (sqlDataReader.Read())
                {
                    bool flag = sqlDataReader.GetDouble(0) > 0.0;
                    if (flag)
                    {
                        ketqua_double = 0.0;
                    }
                    else
                    {
                        ketqua_double = sqlDataReader.GetDouble(0);
                    }
                }
                cnn.Close();
            }
            catch
            {
                ketqua_double = 0.0;
            }
            return ketqua_double.ToString();
        }

        public static bool Truyvan_Boolean(string sql)
        {
            DataTable dataTable = Truyvan_SQL(sql);
            //bool flag = dataTable.Rows.Count > 0;
            if (dataTable.Rows.Count > 0)
            {
                ketqua_bool = true;
            }
            else
            {
                ketqua_bool = false;
            }
            return ketqua_bool;
        }

        public static DataSet Truyvan_SQL_Ds(string sql, string tablename)
        {
            KetnoiCSDL_SQL();
            SqlCommand selectCommand = new SqlCommand(sql, cnn);
            da = new SqlDataAdapter(selectCommand);
            DataSet dataSet = new DataSet();
            da.Fill(dataSet, tablename);
            cnn.Close();
            return dataSet;
        }

        public static DataSet Truyvan_SQL_Ds2(string sql)
        {
            KetnoiCSDL_SQL();
            SqlCommand selectCommand = new SqlCommand(sql, cnn);
            da = new SqlDataAdapter(selectCommand);
            DataSet dataSet = new DataSet();
            da.Fill(dataSet);
            cnn.Close();
            return dataSet;
        }

        public static DataTable Truyvan_SQL(string sql)
        {
            KetnoiCSDL_SQL();
            SqlCommand selectCommand = new SqlCommand(sql, cnn);
            da = new SqlDataAdapter(selectCommand);
            DataTable dataTable = new DataTable();
            da.Fill(dataTable);
            cnn.Close();
            return dataTable;
        }
        public static DataTable GetDataTable(string sSql)
        {
            SqlDataAdapter daAdapter = new SqlDataAdapter();
            SqlCommand cmCommand = new SqlCommand();
            DataTable dt = new DataTable();
            try
            {
                KetnoiCSDL_SQL();
                cmCommand.CommandText = sSql;
                cmCommand.CommandType = CommandType.Text;
                cmCommand.Connection = Connection_SQL.cnn;
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
        public static DataTable Truyvan_PROC2(string sp_name, string PROC_, string FACTORY_)
        {
            KetnoiCSDL_SQL();
            SqlCommand cmd = new SqlCommand(PROC_, cnn);
            DataTable dataTable = new DataTable();
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = sp_name;
            cmd.CommandTimeout = 0;
            cmd.Parameters.Add(new SqlParameter("@FACTORY_", SqlDbType.NVarChar)).Value = FACTORY_;
            SqlDataAdapter sqlDataAdapter = new SqlDataAdapter(cmd);
            sqlDataAdapter.Fill(dataTable);
            Connection_SQL.cnn.Close();
            return dataTable;
        }
        public static string Truyvan_SQL_Datatable(DataTable dt, string query_, string field_Out)
        {
            string value_ = string.Empty;
            DataRow[] DR = dt.Select(query_);
            if (DR.Length == 1)
            {
                value_ = DR[0][field_Out].ToString();
            }
            else
            {
                value_ = string.Empty;
            }
            return value_;
        }
        public static bool Truyvan_SQL_Datatable_Get_field_boolean(DataTable dt, string query_, string field_Out)
        {
            bool value_ = false;
            if (dt.Rows.Count > 0)
            {
                DataView dv = dt.DefaultView;
                dv.RowFilter = query_;
                DataTable dt_new = dv.ToTable();
                if (dt_new.Rows.Count > 0)
                {
                    value_ = bool.Parse(dt_new.Rows[0][field_Out].ToString());
                }
                else
                {
                    value_ = false;
                }
            }
            else
            {
                value_ = false;
            }
            return value_;
        }
        public static DataTable Exec_StoreProc_datatable_Admin(string sStoreProc, ArrayList _parasName, ArrayList _parasValue)
        {

            //Program.gcnConnect_admin.ConnectionString = Program.gsConnectionString_admin;
            string sSql = null;
            //SqlTransaction Trans = null;
            DataTable dt = new DataTable();
            try
            {
                KetnoiCSDL_SQL();
                SqlCommand cmd = new SqlCommand(sStoreProc, cnn);
                //cmd.Connection = Program.gcnConnect_admin;// mod_BaseSys.gcnConnect;
                cmd.CommandTimeout = 0;
                cmd.CommandType = CommandType.StoredProcedure;
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
                //Trans = Program.gcnConnect_admin.BeginTransaction();
                //cmd.Transaction = Trans;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
                //da.SelectCommand = cmd;
                //SqlDependency de = new SqlDependency(cmd);
                //de.OnChange += new OnChangeEventHandler(de_OnChange);
                //da.Fill(dt);
                //dt.Load(cmd.ExecuteReader(CommandBehavior.CloseConnection));
                //cmd.ExecuteNonQuery();
                //Trans.Commit();
                Connection_SQL.cnn.Close();
                return dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi!" + ex.Message);
                //Trans.Rollback();
                return dt;
                //return false;
            }
        }
        public static bool Truyvan_SQL_Datatable_boolean(DataTable dt, string query_)
        {
            bool value_ = false;
            if (dt.Rows.Count > 0)
            {
                DataView dv = dt.DefaultView;
                dv.RowFilter = query_;
                DataTable dt_new = dv.ToTable();
                if (dt_new.Rows.Count > 0)
                {
                    value_ = true;
                }
                else
                {
                    value_ = false;
                }
            }
            else
            {
                value_ = false;
            }
            return value_;
        }
        public static DataTable Truyvan_Get_Table(DataTable dt, string query_dk)
        {
            DataView V1 = dt.DefaultView;
            V1.RowFilter = query_dk;
            //DataRow[] DR = dt.Select(query_dk);
            DataTable dt_ = V1.ToTable();
            return dt_;
        }
        public static DataSet Truyvan_LoadData(string sql)
        {
            KetnoiCSDL_SQL();
            da = new SqlDataAdapter(sql, cnn);
            DataSet dataSet = new DataSet();
            da.Fill(dataSet);
            cnn.Close();
            return dataSet;
        }

        public static void Truyvan_ChangeCSDL(string sql)
        {
            try
            {
                KetnoiCSDL_SQL();
                SqlCommand sqlCommand = new SqlCommand(sql, cnn);
                sqlCommand.ExecuteNonQuery();
                cnn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public static void CapnhatDL(DataGridView DGV)
        {
            KetnoiCSDL_SQL();
            sqlcom = new SqlCommandBuilder(da);
            SqlConnection sqlConnection = new SqlConnection(Constr);
            try
            {
                da.Update((DataTable)DGV.DataSource);
                DGV.Refresh();
                MessageBox.Show("Cập nhật dữ liệu thành công", "Thông báo");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Có lỗi xảy ra, liên hệ nhà cung cấp" + ex.Message, "Thông báo",
                    MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }
        }
        //public static void Create_Auto_Complete_Mode(MetroFramework.Controls.MetroTextBox txt, string sql)
        //{
        //    try
        //    {
        //        Connection_SQL.KetnoiCSDL_SQL();
        //        SqlCommand cmd = new SqlCommand(sql, Connection_SQL.cnn);
        //        SqlDataReader reader = cmd.ExecuteReader();
        //        AutoCompleteStringCollection MyCollection = new AutoCompleteStringCollection();
        //        while (reader.Read())
        //        {
        //            MyCollection.Add(reader.GetString(0));
        //        }

        //        txt.AutoCompleteCustomSource = MyCollection;
        //        Connection_SQL.cnn.Close();
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show("Có lỗi xảy ra, liên hệ nhà cung cấp" + ex.Message, "Thông báo", 
        //            MessageBoxButtons.OK, MessageBoxIcon.Hand);
        //    }
        //}
        //public static void Create_Auto_Complete_Mode_Dev(DevExpress.XtraEditors.TextEdit txt, string sql)
        //{
        //    try
        //    {
        //        Connection_SQL.KetnoiCSDL_SQL();
        //        SqlCommand cmd = new SqlCommand(sql, Connection_SQL.cnn);
        //        SqlDataReader reader = cmd.ExecuteReader();
        //        AutoCompleteStringCollection MyCollection = new AutoCompleteStringCollection();
        //        while (reader.Read())
        //        {
        //            MyCollection.Add(reader.GetString(0));
        //        }

        //        txt.MaskBox.AutoCompleteCustomSource = MyCollection;
        //        txt.MaskBox.AutoCompleteSource = AutoCompleteSource.CustomSource;
        //        txt.MaskBox.AutoCompleteMode = AutoCompleteMode.SuggestAppend;
        //        Connection_SQL.cnn.Close();
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show("Có lỗi xảy ra, liên hệ nhà cung cấp" + ex.Message, "Thông báo",
        //            MessageBoxButtons.OK, MessageBoxIcon.Hand);
        //    }
        //}
        //public static void Create_Auto_Complete_Mode_Dev_proc_jobsheet(DevExpress.XtraEditors.TextEdit txt, string proc,string factory_)
        //{
        //    try
        //    {
        //        Connection_SQL.KetnoiCSDL_SQL();
        //        SqlCommand cmd = new SqlCommand(proc, Connection_SQL.cnn);
        //        cmd.CommandType = CommandType.StoredProcedure;
        //        cmd.Parameters.Add(new SqlParameter("@FACTORY_", SqlDbType.NVarChar)).Value = factory_;
        //        SqlDataReader reader = cmd.ExecuteReader();
        //        AutoCompleteStringCollection MyCollection = new AutoCompleteStringCollection();
        //        while (reader.Read())
        //        {
        //            MyCollection.Add(reader.GetString(0));
        //        }

        //        txt.MaskBox.AutoCompleteCustomSource = MyCollection;
        //        txt.MaskBox.AutoCompleteSource = AutoCompleteSource.CustomSource;
        //        txt.MaskBox.AutoCompleteMode = AutoCompleteMode.SuggestAppend;
        //        Connection_SQL.cnn.Close();
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show("Có lỗi xảy ra, liên hệ nhà cung cấp" + ex.Message, "Thông báo",
        //            MessageBoxButtons.OK, MessageBoxIcon.Hand);
        //    }
        //}
        public static void Create_Auto_Complete_Mode_windows(System.Windows.Forms.TextBox txt, string sql)
        {
            try
            {
                Connection_SQL.KetnoiCSDL_SQL();
                SqlCommand cmd = new SqlCommand(sql, Connection_SQL.cnn);
                SqlDataReader reader = cmd.ExecuteReader();
                AutoCompleteStringCollection MyCollection = new AutoCompleteStringCollection();
                while (reader.Read())
                {
                    MyCollection.Add(reader.GetString(0));
                }

                txt.AutoCompleteCustomSource = MyCollection;
                Connection_SQL.cnn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Có lỗi xảy ra, liên hệ nhà cung cấp" + ex.Message, "Thông báo",
                    MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }
        }
        public static void Create_Auto_Complete_Mode_windows_proc(System.Windows.Forms.TextBox txt, string proc)
        {
            try
            {
                Connection_SQL.KetnoiCSDL_SQL();
                SqlCommand cmd = new SqlCommand(proc, Connection_SQL.cnn);
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataReader reader = cmd.ExecuteReader();
                AutoCompleteStringCollection MyCollection = new AutoCompleteStringCollection();
                while (reader.Read())
                {
                    MyCollection.Add(reader.GetString(0));
                }

                txt.AutoCompleteCustomSource = MyCollection;
                Connection_SQL.cnn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Có lỗi xảy ra, liên hệ nhà cung cấp" + ex.Message, "Thông báo",
                    MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }
        }
        //public static void Create_Auto_Complete_Mode_Metro(MetroFramework.Controls.MetroTextBox txt, string sql)
        //{
        //    try
        //    {
        //        Connection_SQL.KetnoiCSDL_SQL();
        //        SqlCommand cmd = new SqlCommand(sql, Connection_SQL.cnn);
        //        SqlDataReader reader = cmd.ExecuteReader();
        //        AutoCompleteStringCollection MyCollection = new AutoCompleteStringCollection();
        //        while (reader.Read())
        //        {
        //            MyCollection.Add(reader.GetString(0));
        //        }

        //        txt.AutoCompleteCustomSource = MyCollection;
        //        Connection_SQL.cnn.Close();
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show("Có lỗi xảy ra, liên hệ nhà cung cấp" + ex.Message, "Thông báo",
        //            MessageBoxButtons.OK, MessageBoxIcon.Hand);
        //    }
        //}
        public bool Exec_StoreProc(string sStoreProc, ArrayList _parasName, ArrayList _parasValue)
        {
            string sSql = null;
            SqlTransaction Trans = null;
            try
            {
                if (mod_BaseSys.gcnConnect == null)
                {
                    return false;
                }
                else
                {
                    if (mod_BaseSys.gcnConnect.State == ConnectionState.Closed)
                    {
                        mod_BaseSys.gcnConnect.Open();
                    }
                    SqlCommand cmd = new SqlCommand();
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
                    Trans = mod_BaseSys.gcnConnect.BeginTransaction();
                    cmd.Transaction = Trans;
                    cmd.ExecuteNonQuery();
                    Trans.Commit();
                    return true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi!" + ex.Message);
                Trans.Rollback();
                return false;
            }
        }
    }
}
