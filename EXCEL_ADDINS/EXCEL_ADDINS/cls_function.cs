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
using System.Data.SqlClient;
using System.Data.OleDb;
using System.IO;
using System.Security.Authentication.ExtendedProtection;
using Excel = Microsoft.Office.Interop.Excel;


namespace EXCEL_ADDINS
{
    public class cls_function
    {
        public static string _extension = string.Empty;//
        public static string _filename = string.Empty;//
        public static string _fullname = string.Empty;//
        public static string _TableTmp = string.Empty;//;
        public static string _Table = string.Empty;//
        public static string _sheetname = string.Empty;
        public static string _division = string.Empty;
        public static string _error_message = string.Empty;
        public static bool priority_ = false;


        public static bool _1hour = false;
        public static bool _2hour = false;
        public static bool _4hour = false;
        public static bool _Immediate = false;
        public static string _hour = "0";

        public static string Get_List_Column_Forecast(string _delimiter) 
        {
            string _month_desc = "[Y@ (u) M#]";
            //get year forecast
            int _year_forecast = 0;
            //get month forcast
            int _month_forecast = int.Parse(Connection_SQL._fmkey.Substring(4, 2));
            string _list_column_forecast = "";
            int i_ok = 0;
            string _year_forrecast_ok = "";
            //get list month need to sum condition <>0
            for (int i = 1; i <= 24; i++)
            {
                if (i >= _month_forecast)
                {
                    if (i > 12)
                    {
                        i_ok = i - 12;
                        _year_forecast = 1;
                        _year_forrecast_ok = "+" + _year_forecast.ToString();
                    }
                    else
                    {
                        i_ok = i;
                        _year_forrecast_ok = _year_forecast.ToString();
                    }
                    if (_list_column_forecast.Length == 0)
                    {
                        _list_column_forecast = _month_desc.Replace("@", _year_forrecast_ok).Replace("#", i_ok.ToString());
                    }
                    else
                    {
                        _list_column_forecast = _list_column_forecast + _delimiter +_month_desc.Replace("@", _year_forrecast_ok).Replace("#", i_ok.ToString());
                    }
                }
            }
            return _list_column_forecast;
        }
        public static bool Import_ExcelFile(string division_,string filename_,string table_, string sheetname_,string extention_)
        {
            Connection_SQL._division = division_;
            _division = Connection_SQL._division;
            _fullname = Connection_SQL._path + filename_;
            _Table = table_;
            _sheetname = sheetname_+"$";
            _extension = extention_;
            bool _result = false;            
            double rows_excel = 0;
            //double _rows_sql = 0;
            double _rowtmp = 0;            
            try
            {
                //string _listcolumn = Get_List_Column_Forecast("+");
                //MessageBox.Show(_listcolumn);

                //import mới
                string conString = string.Empty;
                switch (_extension.ToUpper())
                {
                    case "XLS": //Excel 97-03.
                        conString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties='Excel 12.0 Xml;HDR=YES'";
                        break;
                    case "XLSB": //Excel 97-03.
                        conString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties='Excel 12.0 Xml;HDR=YES'";
                        break;
                    case "XLSM": //Excel 07 and above.
                        conString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties='Excel 12.0 Xml;HDR=YES'";
                        break;
                    case "XLSX": //Excel 07 and above.
                        conString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties='Excel 12.0 Xml; HDR=YES'";
                        break;
                }
                //Đưa dữ liệu vào datatable---------------------------------------------------------------------
                DataTable dt = new DataTable();
                //MessageBox.Show(_fullname);
                conString = string.Format(conString, _fullname);                
                using (OleDbConnection connExcel = new OleDbConnection(conString))
                {                    
                    using (OleDbCommand cmdExcel = new OleDbCommand())
                    {
                        using (OleDbDataAdapter odaExcel = new OleDbDataAdapter())
                        {
                            cmdExcel.Connection = connExcel;
                            cmdExcel.CommandTimeout = 900000;
                            //Get the name of First Sheet.
                            connExcel.Open();
                            DataTable dtExcelSchema = connExcel.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                            string sheetName = string.Empty;
                            if (_Table == "FC_WF")
                            {
                                for (int i = 0; i < dtExcelSchema.Rows.Count; i++)
                                {
                                    if (dtExcelSchema.Rows[i]["TABLE_NAME"].ToString() == _sheetname)
                                    {
                                        sheetName = dtExcelSchema.Rows[i]["TABLE_NAME"].ToString().Replace("$", "");
                                    }
                                }
                            }
                            //kiểm tra nếu file chuẩn bị insert đã tồn tại trong system thì xóa những dòng chứa file đó và insert lại
                            if (_Table == "FC_WF")
                            {
                                if (sheetName != "WF" && sheetName !="WF_Total")
                                {
                                    _rowtmp = 0;
                                    //MessageBox.Show("sheetName != WF");
                                    ////sqllog.WriteLog(_Table, _Msg_name, _fullname, "Sheet name not match.../");
                                }
                                else
                                {
                                    /*
                                     [Y0 (u) M1],[Y0 (u) M2],[Y0 (u) M3],[Y0 (u) M4],[Y0 (u) M5],[Y0 (u) M6],[Y0 (u) M7],
                                                    [Y0 (u) M8],[Y0 (u) M9],[Y0 (u) M10],[Y0 (u) M11],[Y0 (u) M12],
                                                    [Y+1 (u) M1],[Y+1 (u) M2],[Y+1 (u) M3],[Y+1 (u) M4],[Y+1 (u) M5],[Y+1 (u) M6],
                                                    [Y+1 (u) M7],[Y+1 (u) M8],[Y+1 (u) M9],[Y+1 (u) M10],[Y+1 (u) M11],[Y+1 (u) M12]
                                     */
                                    connExcel.Close();
                                    string sql_ = string.Empty;
                                    //Read Data from First Sheet
                                    if (sheetName == "WF")
                                    {
                                        sql_ = @"SELECT 
                                                    [id],
                                                    [Product type],
                                                    [Forecasting Line],
                                                    [Channel],
                                                    [Time series],
                                                    [Y0 (u) M1],[Y0 (u) M2],[Y0 (u) M3],[Y0 (u) M4],[Y0 (u) M5],[Y0 (u) M6],[Y0 (u) M7],
                                                    [Y0 (u) M8],[Y0 (u) M9],[Y0 (u) M10],[Y0 (u) M11],[Y0 (u) M12],
                                                    [Y+1 (u) M1],[Y+1 (u) M2],[Y+1 (u) M3],[Y+1 (u) M4],[Y+1 (u) M5],[Y+1 (u) M6],
                                                    [Y+1 (u) M7],[Y+1 (u) M8],[Y+1 (u) M9],[Y+1 (u) M10],[Y+1 (u) M11],[Y+1 (u) M12]
                                                From [WF$] 
                                                where [Channel] NOT IN ('O+O') 
                                                and [Time series] IN ('1. Baseline Qty','2. Promo Qty(Single)','4. Launch Qty','6. Total Qty','5. FOC Qty') ";
                                        /*and (" + Get_List_Column_Forecast("+")+")<>0*/
                                        //MessageBox.Show(sql_);
                                        /*[Product type],
                                        [Forecasting Line],
                                        [Channel],
                                        [Time series],*/
                                    }
                                    connExcel.Open();
                                    cmdExcel.CommandText = sql_;
                                    odaExcel.SelectCommand = cmdExcel;
                                    odaExcel.Fill(dt);
                                    connExcel.Close();
                                    _rowtmp = dt.Rows.Count;
                                    //MessageBox.Show("rows: "+_rowtmp.ToString());
                                }
                            }
                        }
                    }
                }
                //MessageBox.Show(_rowtmp.ToString());
                if (_rowtmp > 0)
                {
                    rows_excel = _rowtmp;// dt.Rows.Count;

                    if (_Table == "FC_WF")
                    {
                        New_sp nw = new New_sp();
                        nw.sp_Truncate_FC_FM_Original_Tmp
                        (
                            Connection_SQL._division,
                            Connection_SQL._fmkey
                        );
                        //MessageBox.Show(nw.b_success);
                        if (nw.b_success == "1")
                        {

                            if (dt.Rows.Count > 0)
                            {
                                Connection_SQL.KetnoiCSDL_SQL();
                                using (SqlBulkCopy copy = new SqlBulkCopy(Connection_SQL.cnn))
                                {
                                    if (_Table == "FC_WF")
                                    {
                                        _TableTmp = "FC_FM_Original_" + Connection_SQL._division + "_"+Connection_SQL._fmkey + "_Tmp";
                                        //MessageBox.Show(_TableTmp);
                                        copy.DestinationTableName = _TableTmp;
                                        copy.ColumnMappings.Add("id", "id");
                                        copy.ColumnMappings.Add("Product type", "Product type");
                                        copy.ColumnMappings.Add("Forecasting Line", "SUB GROUP/ Brand");
                                        copy.ColumnMappings.Add("Channel", "Channel");
                                        copy.ColumnMappings.Add("Time series", "Time series");
                                        copy.ColumnMappings.Add("Y0 (u) M1", "Y0 (u) M1");
                                        copy.ColumnMappings.Add("Y0 (u) M2", "Y0 (u) M2");
                                        copy.ColumnMappings.Add("Y0 (u) M3", "Y0 (u) M3");
                                        copy.ColumnMappings.Add("Y0 (u) M4", "Y0 (u) M4");
                                        copy.ColumnMappings.Add("Y0 (u) M5", "Y0 (u) M5");
                                        copy.ColumnMappings.Add("Y0 (u) M6", "Y0 (u) M6");
                                        copy.ColumnMappings.Add("Y0 (u) M7", "Y0 (u) M7");
                                        copy.ColumnMappings.Add("Y0 (u) M8", "Y0 (u) M8");
                                        copy.ColumnMappings.Add("Y0 (u) M9", "Y0 (u) M9");
                                        copy.ColumnMappings.Add("Y0 (u) M10", "Y0 (u) M10");
                                        copy.ColumnMappings.Add("Y0 (u) M11", "Y0 (u) M11");
                                        copy.ColumnMappings.Add("Y0 (u) M12", "Y0 (u) M12");
                                        copy.ColumnMappings.Add("Y+1 (u) M1", "Y+1 (u) M1");
                                        copy.ColumnMappings.Add("Y+1 (u) M2", "Y+1 (u) M2");
                                        copy.ColumnMappings.Add("Y+1 (u) M3", "Y+1 (u) M3");
                                        copy.ColumnMappings.Add("Y+1 (u) M4", "Y+1 (u) M4");
                                        copy.ColumnMappings.Add("Y+1 (u) M5", "Y+1 (u) M5");
                                        copy.ColumnMappings.Add("Y+1 (u) M6", "Y+1 (u) M6");
                                        copy.ColumnMappings.Add("Y+1 (u) M7", "Y+1 (u) M7");
                                        copy.ColumnMappings.Add("Y+1 (u) M8", "Y+1 (u) M8");
                                        copy.ColumnMappings.Add("Y+1 (u) M9", "Y+1 (u) M9");
                                        copy.ColumnMappings.Add("Y+1 (u) M10", "Y+1 (u) M10");
                                        copy.ColumnMappings.Add("Y+1 (u) M11", "Y+1 (u) M11");
                                        copy.ColumnMappings.Add("Y+1 (u) M12", "Y+1 (u) M12");

                                    }
                                    copy.BatchSize = 1000000;
                                    copy.BulkCopyTimeout = 9999999;
                                    copy.WriteToServer(dt);
                                    //kiểm tra số dòng đã import thành công
                                    //DataTable dt2 = new DataTable();                                    
                                    //if (_Table == "FC_WF")
                                    //{
                                    //    dt2 = Connection_SQL.GetDataTable("select 1 from " + _TableTmp);
                                    //}
                                    //else
                                    //{
                                    //    _rows_sql = 0;
                                    //}

                                    
                                    //if (dt2.Rows.Count > 0)
                                    //{
                                    //    _rows_sql = dt2.Rows.Count;
                                    //}
                                    //else
                                    //{
                                    //    _rows_sql = 0;
                                    //}
                                    //if (rows_excel == _rows_sql)
                                    //{
                                    //    _result = true;                                     
                                    //}
                                    //else
                                    //{
                                    //    _result = false;
                                    //    _error_message = "rows_excel <> _rows_sql";
                                    //}
                                }
                                _result = true;
                            }
                            else
                            {
                                _result = false;
                                _error_message = "No data to update...";
                            }
                            
                        }
                        else
                        {
                            _result = false;
                            _error_message = "truncate table fail";
                        }
                    }
                }
                else
                {
                    _result = false;
                    _error_message = "rowtmp==0";
                }
            }
            catch (Exception ex)
            {
                _result = false;
                _error_message = ex.Message;
            }
            
            return _result;
        }
        public static bool Import_ExcelFile_New()
        {
            bool _result = false;
            try
            {
                //if (Connection_SQL._Seledcted_status_row_wf == "Show_Total_Selected")
                //{
                //    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("AddData_INTO_Access_fc_tmp_total");
                //}
                //else if (Connection_SQL._Seledcted_status_row_wf == "Show_All_Selected")
                //{
                //    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("AddData_INTO_Access_fc_tmp_non_total");
                //}
                //New_sp nw = new New_sp();
                //nw.sp_Truncate_FC_FM_Original_Tmp
                //(
                //    Connection_SQL._division,
                //    Connection_SQL._fmkey
                //);
                ////MessageBox.Show(nw.b_success);
                //if (nw.b_success == "1")
                //{
                //    DataTable dt = new DataTable();
                //    dt = Connection_Access.Truyvan_Access("select * from fc_tmp");
                //    //MessageBox.Show(dt.Rows.Count.ToString());
                //    string _TableTmp = "";
                //    Connection_SQL.KetnoiCSDL_SQL();
                //    using (SqlBulkCopy copy = new SqlBulkCopy(Connection_SQL.cnn))
                //    {

                //        _TableTmp = "FC_FM_Original_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + "_Tmp";
                //        //MessageBox.Show(_TableTmp);
                //        //MessageBox.Show(_TableTmp);
                //        copy.DestinationTableName = _TableTmp;
                //        copy.ColumnMappings.Add("id", "id");
                //        copy.ColumnMappings.Add("Product type", "Product type");
                //        copy.ColumnMappings.Add("Forecasting Line", "SUB GROUP/ Brand");
                //        copy.ColumnMappings.Add("Channel", "Channel");
                //        copy.ColumnMappings.Add("Time series", "Time series");
                //        copy.ColumnMappings.Add("Y0 (u) M1", "Y0 (u) M1");
                //        copy.ColumnMappings.Add("Y0 (u) M2", "Y0 (u) M2");
                //        copy.ColumnMappings.Add("Y0 (u) M3", "Y0 (u) M3");
                //        copy.ColumnMappings.Add("Y0 (u) M4", "Y0 (u) M4");
                //        copy.ColumnMappings.Add("Y0 (u) M5", "Y0 (u) M5");
                //        copy.ColumnMappings.Add("Y0 (u) M6", "Y0 (u) M6");
                //        copy.ColumnMappings.Add("Y0 (u) M7", "Y0 (u) M7");
                //        copy.ColumnMappings.Add("Y0 (u) M8", "Y0 (u) M8");
                //        copy.ColumnMappings.Add("Y0 (u) M9", "Y0 (u) M9");
                //        copy.ColumnMappings.Add("Y0 (u) M10", "Y0 (u) M10");
                //        copy.ColumnMappings.Add("Y0 (u) M11", "Y0 (u) M11");
                //        copy.ColumnMappings.Add("Y0 (u) M12", "Y0 (u) M12");
                //        copy.ColumnMappings.Add("Y+1 (u) M1", "Y+1 (u) M1");
                //        copy.ColumnMappings.Add("Y+1 (u) M2", "Y+1 (u) M2");
                //        copy.ColumnMappings.Add("Y+1 (u) M3", "Y+1 (u) M3");
                //        copy.ColumnMappings.Add("Y+1 (u) M4", "Y+1 (u) M4");
                //        copy.ColumnMappings.Add("Y+1 (u) M5", "Y+1 (u) M5");
                //        copy.ColumnMappings.Add("Y+1 (u) M6", "Y+1 (u) M6");
                //        copy.ColumnMappings.Add("Y+1 (u) M7", "Y+1 (u) M7");
                //        copy.ColumnMappings.Add("Y+1 (u) M8", "Y+1 (u) M8");
                //        copy.ColumnMappings.Add("Y+1 (u) M9", "Y+1 (u) M9");
                //        copy.ColumnMappings.Add("Y+1 (u) M10", "Y+1 (u) M10");
                //        copy.ColumnMappings.Add("Y+1 (u) M11", "Y+1 (u) M11");
                //        copy.ColumnMappings.Add("Y+1 (u) M12", "Y+1 (u) M12");

                //        copy.BatchSize = 1000000;
                //        copy.BulkCopyTimeout = 9999999;
                //        copy.WriteToServer(dt);
                //_result = true;
                //    }
                //}
                //else
                //{
                //    _error_message = "Truncate data fail.../";
                //    _result = false;
                //}
                Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("UpdateForecast_ChangedOnly_Optimized");
                _result = true;

            }
            catch (Exception ex)
            {
                _error_message = ex.Message;
                _result = false;
                //MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            return _result;
        }

        public static bool Import_ExcelFile_BOM()
        {
            bool _result = false;
            try
            {
                Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("AddData_INTO_Access_fc_bom_tmp");
                New_sp nw = new New_sp();
                nw.sp_Truncate_FC_BOM_Tmp
                (
                    Connection_SQL._division,
                    Connection_SQL._fmkey
                );
                //MessageBox.Show(nw.b_success);
                if (nw.b_success == "1")
                {
                    DataTable dt = new DataTable();
                    dt = Connection_Access.Truyvan_Access("select * from fc_bom_tmp");
                    //MessageBox.Show(dt.Rows.Count.ToString());
                    string _TableTmp = "";
                    Connection_SQL.KetnoiCSDL_SQL();
                    using (SqlBulkCopy copy = new SqlBulkCopy(Connection_SQL.cnn))
                    {

                        _TableTmp = "FC_BomHeader_" + Connection_SQL._division + "_" + Connection_SQL._fmkey + "_Excel_Tmp";
                        //MessageBox.Show(_TableTmp);
                        //MessageBox.Show(_TableTmp);
                        copy.DestinationTableName = _TableTmp;
                        copy.ColumnMappings.Add("Bundle Code", "Bundle Code");
                        copy.ColumnMappings.Add("Bundle name", "Bundle name");
                        copy.ColumnMappings.Add("Channel", "Channel");
                        copy.ColumnMappings.Add("Y0 (u) M1", "Y0 (u) M1");
                        copy.ColumnMappings.Add("Y0 (u) M2", "Y0 (u) M2");
                        copy.ColumnMappings.Add("Y0 (u) M3", "Y0 (u) M3");
                        copy.ColumnMappings.Add("Y0 (u) M4", "Y0 (u) M4");
                        copy.ColumnMappings.Add("Y0 (u) M5", "Y0 (u) M5");
                        copy.ColumnMappings.Add("Y0 (u) M6", "Y0 (u) M6");
                        copy.ColumnMappings.Add("Y0 (u) M7", "Y0 (u) M7");
                        copy.ColumnMappings.Add("Y0 (u) M8", "Y0 (u) M8");
                        copy.ColumnMappings.Add("Y0 (u) M9", "Y0 (u) M9");
                        copy.ColumnMappings.Add("Y0 (u) M10", "Y0 (u) M10");
                        copy.ColumnMappings.Add("Y0 (u) M11", "Y0 (u) M11");
                        copy.ColumnMappings.Add("Y0 (u) M12", "Y0 (u) M12");
                        copy.ColumnMappings.Add("Y+1 (u) M1", "Y+1 (u) M1");
                        copy.ColumnMappings.Add("Y+1 (u) M2", "Y+1 (u) M2");
                        copy.ColumnMappings.Add("Y+1 (u) M3", "Y+1 (u) M3");
                        copy.ColumnMappings.Add("Y+1 (u) M4", "Y+1 (u) M4");
                        copy.ColumnMappings.Add("Y+1 (u) M5", "Y+1 (u) M5");
                        copy.ColumnMappings.Add("Y+1 (u) M6", "Y+1 (u) M6");
                        copy.ColumnMappings.Add("Y+1 (u) M7", "Y+1 (u) M7");
                        copy.ColumnMappings.Add("Y+1 (u) M8", "Y+1 (u) M8");
                        copy.ColumnMappings.Add("Y+1 (u) M9", "Y+1 (u) M9");
                        copy.ColumnMappings.Add("Y+1 (u) M10", "Y+1 (u) M10");
                        copy.ColumnMappings.Add("Y+1 (u) M11", "Y+1 (u) M11");
                        copy.ColumnMappings.Add("Y+1 (u) M12", "Y+1 (u) M12");

                        copy.BatchSize = 1000000;
                        copy.BulkCopyTimeout = 9999999;
                        copy.WriteToServer(dt);
                        _result = true;
                    }
                }
                else
                {
                    _error_message = "Truncate data fail.../";
                    _result = false;
                }
            }
            catch (Exception ex)
            {
                _error_message = ex.Message;
                _result = false;
                //MessageBox.Show(ex.Message, "[Loreal VN]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            return _result;
        }
        //public static void Save_FC(string sheetname_, string type_refresh_)
        //{
        //    bool result = false;
        //    try
        //    {

        //        //result = Import_ExcelFile(Connection_SQL._division, Connection_SQL._FC_Filename, "FC_WF", sheetname_, "xlsm");
        //        result = Import_ExcelFile_New();
        //        //MessageBox.Show(result.ToString());
        //        if (result)
        //        {
        //            //MessageBox.Show("Update");
        //            //1. tính toán lại total & O+O & BP Gap % + Unit with FC
        //            New_sp nw = new New_sp();
        //            nw.sp_tag_update_wf_calculation_fc_unit_Refresh_All
        //            (
        //                Connection_SQL._division,
        //                Connection_SQL._fmkey,
        //                Connection_SQL._Seledcted_status_row_wf,
        //                "fc"//type_refresh_.ToUpper()
        //            );
        //            if (nw.b_success == "1")
        //            {
        //                result = true;
        //            }
        //            else
        //            {
        //                result = false;
        //                MessageBox.Show(nw.c_errmsg, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        result = false;
        //        MessageBox.Show(ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
        //    }
        //    return result;
        //}
        public static void refresh_WF_Question(bool question_)
        {            
            if (Globals.ThisAddIn.Application.ActiveWorkbook.Name.IndexOf(Connection_SQL._FC_Filename)>=0)
            {
                if (question_)
                {
                    //0. hỏi người dùng trước khi thực thi
                    DialogResult drl = MessageBox.Show("Do you want to refresh data?", "[Loreal VN]", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                    if (drl == DialogResult.Yes)
                    {
                        //2.1 Load lại data từ data lake xuống WF excel
                        Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_fc");// ("Get_WF_by_Type_view_Unit");
                    }
                }
                else
                {
                    //2.1 Load lại data từ data lake xuống WF excel
                    Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Get_WF_fc");// ("Get_WF_by_Type_view_Unit");
                }
            }
            else
            {                
                MessageBox.Show("this wotkbook not allow run this function.../", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
        
        //public static void Save_Only_FC(string type_refresh_)
        //{
        //    try
        //    {
        //        bool result = true;
        //        result = Import_ExcelFile_New();
        //        if (result)
        //        {
        //            //MessageBox.Show("Update");
        //            //1. tính toán lại total & O+O & BP Gap % + Unit with FC
        //            New_sp nw = new New_sp();
        //            nw.sp_tag_update_wf_calculation_fc_unit_Refresh_All
        //            (
        //                Connection_SQL._division,
        //                Connection_SQL._fmkey,
        //                Connection_SQL._Seledcted_status_row_wf,
        //                "fc"//type_refresh_.ToUpper()
        //            );
        //            if (nw.b_success == "1")
        //            {
        //                result = true;
        //            }
        //            else
        //            {
        //                result = false;
        //                MessageBox.Show(nw.c_errmsg, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //            }
        //        }
        //        else
        //        {
        //            MessageBox.Show("Import tmp data fail[EXCEL --> Access --> SQL]", "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Error);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
        //    }
        //}
        public static string path_folder(string ApplicationNAme)
        {
            string _result = string.Empty;
            try
            {
                DataTable dt = new DataTable();
                dt = Connection_SQL.GetDataTable(@"select
	                                [ApplicationName]=ISNULL(Config1,''),
	                                [Path]=ISNULL(Config2,'')
                                from SysConfigValue (NOLOCK) 
                                where ConfigHeaderID=66
                                and ISNULL(Config1,'')='"+ ApplicationNAme + "'");
                if (dt.Rows.Count > 0)
                {
                    _result = dt.Rows[0]["Path"].ToString();
                }
            }
            catch
            {
                _result = "ERROR";
            }
            return _result;
        }
        public static bool Check_form_is_open(string _formName)
        {
            bool result = false;
            FormCollection fc = Application.OpenForms;
            foreach (Form frm in fc)
            {
                //iterate through
                if (frm.Name == _formName)
                {
                    result = true;
                }
            }
            return result;
        }

        public static void CopyFilesRecursively(string sourcePath, string targetPath)
        {
            //Now Create all of the directories
            foreach (string dirPath in Directory.GetDirectories(sourcePath, "*", SearchOption.AllDirectories))
            {
                Directory.CreateDirectory(dirPath.Replace(sourcePath, targetPath));
            }

            //Copy all the files & Replaces any files with the same name
            foreach (string newPath in Directory.GetFiles(sourcePath, "*.*", SearchOption.AllDirectories))
            {
                File.Copy(newPath, newPath.Replace(sourcePath, targetPath), true);
            }
        }
        public static void Open_wb_excel(string _pathfile)
        {
            //Excel.Application objexcel;
            //Excel.Workbook wbexcel;
            //bool wbexists;
            //Excel.Worksheet objsht;
            //Excel.Range objrange;

            //objexcel = new Excel.Application();
            //if (System.IO.Directory.GetFiles("C:\\csharp\\error report1.xls") = "")
            //{
            //    wbexcel.NewSheet();
            //}

            //else
            //{
            //    wbexcel.Open("C:\\csharp\\error report1.xls");
            //    objsht = ("sheet1");
            //}
            //objsht.Activate();
            if (File.Exists(_pathfile))
            {
                System.Diagnostics.Process.Start(_pathfile);
            }
        }
        public static void get_action(string _type)
        {
            _1hour = false;
            _2hour = false;
            _4hour = false;
            _Immediate = false;
            if (_type.ToUpper() == "1HOUR")
            {
                _1hour = true;
                _hour = "1";
            }
            else if (_type.ToUpper() == "2HOUR")
            {
                _2hour = true;
                _hour = "2";
            }
            else if (_type.ToUpper() == "4HOUR")
            {
                _4hour = true;
                _hour = "3";
            }
            else if (_type.ToUpper() == "IMMEDIATE")
            {
                _Immediate = true;
                _hour = "0";
            }
        }
        public static void Update_Version_table(string type_)
        {
            try
            {
                get_action(type_);
                New_sp nw = new New_sp();
                nw.sp_Add_Update_Version
                (
                    Connection_SQL._userID,
                    "FC",
                    _hour
                );
                if (nw.b_success == "1")
                {
                    if (_Immediate)
                    {
                        //close BI file
                        try
                        {
                            Globals.ThisAddIn.Application.Workbooks[Globals.ThisAddIn.Application.ActiveWorkbook.Name].Application.Run("Close_Workbooks");
                        }
                        catch
                        {

                        }
                        //download new exe and install
                        try
                        {
                            System.Diagnostics.Process.Start(Connection_SQL._Accesspath + "Install_Update_exe.bat");

                            ////re-open WF again
                            //try
                            //{
                            //    cls_function.Open_wb_excel(Connection_SQL._Accesspath + "FC_WORKING_FILE.xlsm");
                            //}
                            //catch (Exception ex)
                            //{
                            //    MessageBox.Show(ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                            //}
                        }
                        catch(Exception ex)
                        {
                            MessageBox.Show(ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                        }
                        
                    }
                }
                else
                {
                    MessageBox.Show(nw.c_errmsg, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "[L'Oreal]", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
        public static bool Check_user_action()
        {
            bool _action = false;
            DataTable dt_user_info = new DataTable();
            //MessageBox.Show(Connection_SQL._userID);
            dt_user_info = Connection_SQL.GetDataTable(@"select [Action] from V_FC_CONFIG_USER_ALLOW where Division='" + Connection_SQL._division + "' and active = 1 and userid = '" + Connection_SQL._userID + "'");
            if (dt_user_info.Rows.Count == 0)
            {
                //MessageBox.Show("User name: " + Connection_SQL._userID + " invalid");
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
    }
}
