using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WinFormsApp2
{
    public class New_sp
    {
        public string b_success;
        public string c_errmsg;

        public void sp_Filter_GAP_DPvsBP
        (
             string Division,
             string FM_KEY,
             string Type_UNIT_VALUE,
             string abs,
             string compare,
             string compare_value,
             string List_channel,
             string List_MaterialType,
             string ListMonth,
             string Method_Calculation,
             string signature,
             string HERO,
             string Category,
             string Sub_Category,
             string Group_Class
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Filter_GAP_DPvsBP", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Type_UNIT_VALUE", Type_UNIT_VALUE);
            sqlCommand.Parameters.AddWithValue("@abs", abs);
            sqlCommand.Parameters.AddWithValue("@compare", compare);
            sqlCommand.Parameters.AddWithValue("@compare_value", compare_value);
            sqlCommand.Parameters.AddWithValue("@List_channel", List_channel);
            sqlCommand.Parameters.AddWithValue("@List_MaterialType", List_MaterialType);
            sqlCommand.Parameters.AddWithValue("@ListMonth", ListMonth);
            sqlCommand.Parameters.AddWithValue("@Method_Calculation", Method_Calculation);
            sqlCommand.Parameters.AddWithValue("@signature", signature);
            sqlCommand.Parameters.AddWithValue("@HERO", HERO);
            sqlCommand.Parameters.AddWithValue("@Category", Category);
            sqlCommand.Parameters.AddWithValue("@Sub_Category", Sub_Category);
            sqlCommand.Parameters.AddWithValue("@Group_Class", Group_Class);
            //-----------------------------
            //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
            //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

            sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
            sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

            sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
            sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

            sqlCommand.ExecuteNonQuery();
            //-------------------------------------------------------
            //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
            b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
            if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
            {
                c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
            }
            Connection_SQL.cnn.Close();
        }
        public void sp_Filter_GAP_Adjust_OK
        (
             string Division,
             string FM_KEY,
             string ID,
             string ColumnName,
             string Value
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Filter_GAP_Adjust_OK", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@ID", ID);
            sqlCommand.Parameters.AddWithValue("@ColumnName", ColumnName);
            sqlCommand.Parameters.AddWithValue("@Value", Value);
            //-----------------------------
            //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
            //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

            sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
            sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

            sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
            sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

            sqlCommand.ExecuteNonQuery();
            //-------------------------------------------------------
            //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
            b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
            if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
            {
                c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
            }
            Connection_SQL.cnn.Close();
        }
        public void sp_Update_Filter_WF
        (
             string Division,
             string FM_KEY,
             string ListColumn
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Update_Filter_WF", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@ListColumn", ListColumn);
            //-----------------------------
            //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
            //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

            sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
            sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

            sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
            sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

            sqlCommand.ExecuteNonQuery();
            //-------------------------------------------------------
            //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
            b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
            if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
            {
                c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
            }
            Connection_SQL.cnn.Close();
        }
    }
}
