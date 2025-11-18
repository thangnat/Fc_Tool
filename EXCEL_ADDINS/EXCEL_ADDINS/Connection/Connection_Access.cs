using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.OleDb;
using System.Data;
using System.Windows.Forms;

namespace EXCEL_ADDINS
{
    public class Connection_Access
    {
        public static string constr_Access = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source= " 
            + Connection_SQL._Accesspath+"FC_SysData.mdb;Jet OLEDB:Database Password='123'";

        public static OleDbConnection con_Access;

        public static bool ketqua_boolmdb;

        public static void KetnoiCSDL_Access()
        {
            try
            {
                con_Access = new OleDbConnection(constr_Access);
                bool flag = (con_Access.State == ConnectionState.Closed);
                if (flag)
                {
                    con_Access.Open();
                    //MessageBox.Show("ket noi thanh cong...");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Connection fail...\n" + ex.Message, mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        public static void Ngatketnoi_Access()
        {
            con_Access.Close();
        }

        public static DataTable Truyvan_Access(string sql_Access)
        {
            KetnoiCSDL_Access();
            OleDbCommand selectCommand = new OleDbCommand(sql_Access, con_Access);
            OleDbDataAdapter oleDbDataAdapter = new OleDbDataAdapter(selectCommand);
            DataTable dataTable = new DataTable();
            oleDbDataAdapter.Fill(dataTable);
            con_Access.Close();
            return dataTable;
        }

        public static void ChangeCSDL_Access(string sql_Access)
        {
            try
            {
                KetnoiCSDL_Access();
                OleDbCommand oleDbCommand = new OleDbCommand(sql_Access, con_Access);
                oleDbCommand.ExecuteNonQuery();
                Ngatketnoi_Access();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public static bool Truyvan_Booleanmdb(string sql)
        {
            DataTable dataTable = Truyvan_Access(sql);
            bool flag = dataTable.Rows.Count > 0;
            if (flag)
            {
                ketqua_boolmdb = true;
            }
            else
            {
                ketqua_boolmdb = false;
            }
            return ketqua_boolmdb;
        }

        
    }
}
