using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EXCEL_ADDINS
{
    class New_sp
    {
        public string b_success;
        public string c_errmsg;
        //public string c_subject;
        //public string c_Html;
        //public string b_id_title;
        //public string b_id_detail;
        //public string b_rows;
        //public string c_CustomerID_Out;
        //public string c_KeyID_Out;
        //public string c_KeyID_Out2;
        public void sp_Update_Bom_Header_New
        (
            string Division,
            string FM_KEY,
            string Channel,
            string BundleCode,
            string ColumnName,
            string Value
            //,string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Update_Bom_Header_New", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Channel", Channel);
            sqlCommand.Parameters.AddWithValue("@BundleCode", BundleCode);
            sqlCommand.Parameters.AddWithValue("@ColumnName", ColumnName);
            sqlCommand.Parameters.AddWithValue("@Value", Value);
            //sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_Update_Bom_Header_New2
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Update_Bom_Header_New2", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Channel", Channel);
            //sqlCommand.Parameters.AddWithValue("@BundleCode", BundleCode);
            //sqlCommand.Parameters.AddWithValue("@ColumnName", ColumnName);
            //sqlCommand.Parameters.AddWithValue("@Value", Value);
            //sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        //public void sp_FC_GetList_Subgroup
        //(
        //    string Division,
        //    string Searchtext
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_FC_GetList_Subgroup", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@Searchtext", Searchtext);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        public void sp_FC_FM_Export_Excel_File_OK
        (
            string Division,
            string FMKEY,
            string Timeseries,
            string subgrp
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_FC_FM_Export_Excel_File_OK", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FMKEY", FMKEY);
            sqlCommand.Parameters.AddWithValue("@Timeseries", Timeseries);
            sqlCommand.Parameters.AddWithValue("@subgrp", subgrp);
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

        public void sp_Truncate_FC_FM_Original_Tmp
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Truncate_FC_FM_Original_Tmp", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Timeseries", Timeseries);
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
        public void sp_Truncate_FC_BOM_Tmp
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Truncate_FC_BOM_Tmp", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Timeseries", Timeseries);
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
        public void sp_tag_update_wf_fc_adjust_unit
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_fc_adjust_unit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Timeseries", Timeseries);
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
        public void sp_tag_update_wf_fc_adjust_Unit_New
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_fc_adjust_Unit_New", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Timeseries", Timeseries);
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
        public void sp_tag_update_wf_calculation_fc_unit_Refresh
        (
            string Division,
            string FM_KEY,
            string Show_Selected_Status
            //string Type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_calculation_fc_unit_Refresh", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Show_Selected_Status", Show_Selected_Status);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_tag_update_wf_calculation_fc_unit_Refresh_All
        (
            string Division,
            string FM_KEY,
            string Show_Selected_Status,
            string type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_calculation_fc_unit_Refresh_All", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Show_Selected_Status", Show_Selected_Status);
            sqlCommand.Parameters.AddWithValue("@Type", type);//All, null
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
        public void sp_Update_Bom_Header_Excel
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Update_Bom_Header_Excel", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Show_Selected_Status", Show_Selected_Status);
            //sqlCommand.Parameters.AddWithValue("@Type", type);//All, null
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
        public void sp_tag_update_wf_calculation_fc_unit_Refresh_All_TEST
        (
            string Division,
            string FM_KEY,
            string Show_Selected_Status,
            string type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_calculation_fc_unit_Refresh_All_TEST", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Show_Selected_Status", Show_Selected_Status);
            sqlCommand.Parameters.AddWithValue("@Type", type);//All, null
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
        public void sp_Add_Update_Version
        (
            string Manv,
            string Application,
            string Hour
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Add_Update_Version", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Manv", @Manv);
            sqlCommand.Parameters.AddWithValue("@Application", Application);
            sqlCommand.Parameters.AddWithValue("@Hour", int.Parse(Hour));
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

        public void sp_Sum_FC_FM_baseLine
        (
            string Division,
            string FM_KEY,
            string Type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Sum_FC_FM_baseLine", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_Add_FC_BFL_Master
        (
            string Division,
            string FM_KEY,
            string Month,
            string Type,
            string OnlyTrend
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Add_FC_BFL_Master", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Month", Month);
            sqlCommand.Parameters.AddWithValue("@Type", Type);
            sqlCommand.Parameters.AddWithValue("@OnlyTrend", int.Parse(OnlyTrend));
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
        public void sp_Sum_FC_FM_baseLine_new
        (
            string Division,
            string FM_KEY
            ,string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Sum_FC_FM_baseLine_new", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", AllowTotal);
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
        public void sp_tag_update_wf_FM_unit
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_FM_unit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        //public void sp_tag_gen_fm_non_modeling_new
        //(
        //    string Division,
        //    string FM_KEY,
        //    string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_fm_non_modeling_new", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        public void sp_tag_gen_fm_non_modeling_new
        (
            string Division,
            string FM_KEY,
            string Type,
            string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_fm_non_modeling_new", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Type", Type);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", AllowTotal);
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
        public void sp_tag_update_wf_FM_Non_Modeling_unit
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_FM_Non_Modeling_unit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_tag_gen_SUBGROUP_VLOOKUP
        (
            string Division,
            string Active
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_SUBGROUP_VLOOKUP", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@Active", Active);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_Gen_BomHeader_Forecast
        (
            string Division,
            string FM_KEY,
            string Type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Gen_BomHeader_Forecast", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_Gen_BomHeader_Forecast_FDR
        (
            string Division,
            string FM_KEY
            //,string Type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Gen_BomHeader_Forecast_FDR", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_Gen_BomHeader_Forecast_FOC_TO_VP
        (
            string Division,
            string FM_KEY
        //,string Type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Gen_BomHeader_Forecast_FOC_TO_VP", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_Gen_BomHeader_Forecast_SO_OPTIMUS
        (
            string Division,
            string FM_KEY
        //,string Type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Gen_BomHeader_Forecast_SO_OPTIMUS", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        //public void sp_tag_gen_budget_budget
        //(
        //    string Division,
        //    string FM_KEY,
        //    string AllowTotal
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_budget_budget", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    sqlCommand.Parameters.AddWithValue("@AllowTotal", AllowTotal);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        public void sp_tag_gen_budget_budget_New
        (
            string Division,
            string FM_KEY
            , string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_budget_budget_New", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_tag_gen_budget_pre_budget_new
        (
            string Division,
            string FM_KEY
            , string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_budget_pre_budget_new", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        //public void sp_tag_update_wf_budget_unit
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_budget_unit", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        //public void sp_tag_update_wf_budget_value
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_budget_value", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        //public void sp_tag_gen_budget_pre_budget
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_budget_pre_budget", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        //public void sp_tag_update_wf_pre_budget_unit
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_pre_budget_unit", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        //public void sp_tag_update_wf_pre_budget_value
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_pre_budget_value", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        //public void sp_tag_gen_budget_trend
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_budget_trend", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        public void sp_tag_gen_budget_trend_new
        (
            string Division,
            string FM_KEY
            , string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_budget_trend_new", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        //public void sp_tag_update_wf_trend_unit
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_trend_unit", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        //public void sp_tag_update_wf_trend_value
        //(
        //    string Division,
        //    string FM_KEY
        ////,string Type
        //)
        //{
        //    Connection_SQL.KetnoiCSDL_SQL();
        //    SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_trend_value", Connection_SQL.cnn);
        //    sqlCommand.CommandType = CommandType.StoredProcedure;
        //    sqlCommand.CommandTimeout = 999999;
        //    sqlCommand.Parameters.AddWithValue("@Division", Division);
        //    sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
        //    //sqlCommand.Parameters.AddWithValue("@Type", Type);
        //    //-----------------------------
        //    //sqlCommand.Parameters.Add("@ID_OUT", SqlDbType.NVarChar, 500);
        //    //sqlCommand.Parameters["@ID_OUT"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@b_Success", SqlDbType.Int);
        //    sqlCommand.Parameters["@b_Success"].Direction = ParameterDirection.Output;

        //    sqlCommand.Parameters.Add("@c_errmsg", SqlDbType.NVarChar, 250);
        //    sqlCommand.Parameters["@c_errmsg"].Direction = ParameterDirection.Output;

        //    sqlCommand.ExecuteNonQuery();
        //    //-------------------------------------------------------
        //    //c_KeyID_Out = sqlCommand.Parameters["@ID_OUT"].Value.ToString();
        //    b_success = sqlCommand.Parameters["@b_Success"].Value.ToString();
        //    if (sqlCommand.Parameters["@c_errmsg"].Value.ToString().Length > 0)
        //    {
        //        c_errmsg = sqlCommand.Parameters["@c_errmsg"].Value.ToString();
        //    }
        //    Connection_SQL.cnn.Close();
        //}
        public void sp_Gen_WF_Value_New
        (
            string Division,
            string FM_KEY
            ,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Gen_WF_Value_New", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_Promo_Bom
        (
            string Division,
            string FM_KEY
            //, string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_Promo_Bom", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_NORMAL
        (
            string Division,
            string FM_KEY
        //, string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_add_FC_SI_Group_FC_SO_OPTIMUS_NORMAL", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_add_FC_SI_Group_FC_SI_FOC
        (
            string Division,
            string FM_KEY
            , string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_add_FC_SI_Group_FC_SI_FOC", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_tag_add_FC_SI_Group_FC_SI_Launch_Single
        (
            string Division,
            string FM_KEY
        , string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_add_FC_SI_Group_FC_SI_Launch_Single", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom
        (
            string Division,
            string FM_KEY
            , string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_add_FC_SI_Group_FC_SI_Promo_Bom", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New
        (
            string Division,
            string FM_KEY,
            string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_add_FC_SI_Group_FC_SI_Promo_Single_New", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_tag_update_wf_value_fc_02_years
        (
            string Division,
            string FM_KEY
            //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_value_fc_02_years", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_git
        (
            string Division
            //string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_git", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            //sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_sit
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_sit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_calculate_total
        (
            string Division,
            string FM_KEY,
            string type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_calculate_total", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@type", type);
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
        public void sp_tag_update_wf_sit_day
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_sit_day", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_soh
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_soh", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_mtd_si
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_mtd_si", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_ver_m_1
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_ver_m_1", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_ver_m_1_unit
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_ver_m_1_unit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_FC_GIT_NEW
        (
            string Division,
            string FM_KEY
            //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_FC_GIT_New", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_gen_soh
        (
            string Division,
            string FM_KEY
            //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_gen_soh", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        
        public void sp_tag_update_wf_value_pass_02_years_new
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_value_pass_02_years_new", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_Update_WF_AVG_HIS_unit
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_Update_WF_AVG_HIS_unit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_Unit
        (
            string Division,
            string FM_KEY
        //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_Update_WF_AVG_HIS_3M_Y0_SI_Unit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_total_slob
        (
            string Division,
            string FM_KEY
            ,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_total_slob", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_O_O_slob
        (
            string Division,
            string FM_KEY
            , string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_O_O_slob", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_zv14_02_year_actual
        (
            string Division,
            string FM_KEY
            //,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_zv14_02_year_actual", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_tag_update_wf_pass_02_years_new
        (
            string Division,
            string FM_KEY
            ,string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_wf_pass_02_years_new", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_tag_update_BP_unit
        (
            string Division,
            string FM_KEY,
            string ImportType
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_BP_unit", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@ImportType", int.Parse(ImportType));
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
        public void sp_Check_GAP_NEW
        (
            string Division,
            string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Check_GAP_NEW", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@ImportType", int.Parse(ImportType));
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
        public void sp_FC_Create_Bomheader_Tmp
        (
            string Division
            //,string FM_KEY
            //, string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_FC_Create_Bomheader_Tmp", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            //sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_fc_adjust_Total_WF
        (
            string Division
            ,string FM_KEY
        //, string AllowTotal
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_fc_adjust_Total_WF", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@AllowTotal", int.Parse(AllowTotal));
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
        public void sp_Create_V_His_SI_Final
        (
             string Division
            ,string FM_KEY
            ,string Alias
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Create_V_His_SI_Final", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@Alias", Alias);
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
        public void sp_Add_ZV14_Forecast
        (
             string Division
            //, string FM_KEY
            //, string Alias
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Add_ZV14_Forecast", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            //sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Alias", Alias);
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
        public void sp_Gen_WF_New3
        (
             string Division,
             string FM_KEY,
             string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Gen_WF_New3", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
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
        public void sp_Apply_Selected_function_into_system
        (
             string Division,
             string FM_KEY,
             string List_ID,
             //,string List_Signature
             string List_selected
             
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Apply_Selected_function_into_system", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@List_ID", List_ID);
            //sqlCommand.Parameters.AddWithValue("@List_Signature", List_Signature);
            sqlCommand.Parameters.AddWithValue("@List_selected", List_selected);
            //-----------------------------s
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
        public void sp_Apply_Selected_function_into_system_New
        (
             string Division
             ,string FM_KEY
             ,string List_ID
             ,string List_Signature
             ,string List_selected
             ,string TypeView
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Apply_Selected_function_into_system_New", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            sqlCommand.Parameters.AddWithValue("@List_ID", List_ID);
            sqlCommand.Parameters.AddWithValue("@List_Signature", List_Signature);
            sqlCommand.Parameters.AddWithValue("@List_selected", List_selected);
            sqlCommand.Parameters.AddWithValue("@TypeView", TypeView);
            //-----------------------------s
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
        public void sp_change_password_Login
        (
             string UserID,
             string Password,
             string Repasswrod
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_change_password_Login", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@UserID", UserID);
            sqlCommand.Parameters.AddWithValue("@Password", Password);
            sqlCommand.Parameters.AddWithValue("@Repasswrod", Repasswrod);
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
        public void sp_Update_WF_Master
        (
             string Division,
             string FM_Key
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Update_WF_Master", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_Key", FM_Key);
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
        public void sp_add_FC_Spectrum
        (
             string Division,
             string FM_Key
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_add_FC_Spectrum", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_Key", FM_Key);
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
        public void sp_FC_FM_Original_Add_More_NEW
        (
             string Division,
             string FM_Key,
             string Allow_Import_main
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_FC_FM_Original_Add_More_NEW", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_Key", FM_Key);
            sqlCommand.Parameters.AddWithValue("@Allow_Import_main", int.Parse(Allow_Import_main));
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
        public void sp_select_Forecasting_Line
        (
             string Division,
             string Subgrp,
             string Type
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_select_Forecasting_Line", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@Subgrp", Subgrp);
            sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_Run_SO_HIS_FINAL
        (
             string Division,
             string periodkey
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_Run_SO_HIS_FINAL", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@periodkey", periodkey);//fill in FM KEY
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_fc_fm_risk_3M
        (
             string Division,
             string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_fc_fm_risk_3M", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
        public void sp_tag_update_slob_wf
        (
             string Division,
             string FM_KEY
        )
        {
            Connection_SQL.KetnoiCSDL_SQL();
            SqlCommand sqlCommand = new SqlCommand("sp_tag_update_slob_wf", Connection_SQL.cnn);
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.CommandTimeout = 999999;
            sqlCommand.Parameters.AddWithValue("@Division", Division);
            sqlCommand.Parameters.AddWithValue("@FM_KEY", FM_KEY);
            //sqlCommand.Parameters.AddWithValue("@Type", Type);
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
