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
using DevExpress.Utils;
using DevExpress.XtraEditors.Repository;
using DevExpress.XtraGrid.Columns;
using DevExpress.XtraGrid.Views.Grid;
using DevExpress.XtraGrid;
using System.Collections;
using DevExpress.XtraSplashScreen;

namespace WinFormsApp2
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


        public static DataTable dt_menu = null;
        public static string _formatDate = "dd/MM/yyyy";
        public static string _formatint = "N0";
        public static string _formatdouble0 = "N0";
        public static string _formatdouble2 = "N2";
        public static string _formatdouble4 = "N4";
        public static string _promt = "Please waiting a second.....";

        public int _ConfigheaderID = -1;
        //Repository
        RepositoryItemToggleSwitch riToggleSwitch_Config = new RepositoryItemToggleSwitch();

        public static string decimalString = Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalSeparator;
        public static char decimalChar = Convert.ToChar(decimalString);
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
        public static DataTable Getgridconfig(int _type, string _tablename)
        {
            DataTable dt = new DataTable();
            ArrayList arr_p1 = new ArrayList() { "@type", "@table_name" };
            ArrayList arr_v1 = new ArrayList() { _type, _tablename };
            dt = Connection_SQL.Exec_StoreProc_datatable_Admin("sp_GetSetGridViewWidthConfig", arr_p1, arr_v1);
            return dt;
        }
        public static string Right(string param, int length)
        {
            string result = "";
            //do a length check first so we don't  cause an error
            //if length is longer than the string length then just get
            //the whole string.
            if (param.Length > 0)
            {
                if (length > param.Length)
                {
                    length = param.Length;
                }
                //start at the index based on the length of the string minus
                //the specified length and assign it a variable
                result = param.Substring(param.Length - length, length);
            }
            //return the result of the operation
            return result;
        }
        public static string Left(string param, int length)
        {
            string result = "";
            //do a length check first so we don't  cause an error
            //if length is longer than the string length then just get
            //the whole string.
            if (param.Length > 0)
            {
                if (length > param.Length)
                {
                    length = param.Length;
                }
                //start at the beginning and get
                //the specified length and assign it a variable
                result = param.Substring(0, length);
            }
            //return the result of the operation
            return result;
        }
        public static string Mid(string param, int start, int length)
        {
            string result = "";
            //do a length check first so we don't  cause an error
            //if length is longer than the string length then just get
            //the rest of the string.
            if ((param.Length > 0) && (start < param.Length))
            {
                if (start + length > param.Length)
                {
                    length = param.Length - start;
                }
                result = param.Substring(start, length);
            }
            //return the result of the operation
            return result;
        }
        public static string UCase(string param)
        {
            string result = "";
            char[] array = param.ToCharArray();
            if (array.Length >= 1)
            {
                result = param.ToUpper();
            }
            return result;
        }
        public static void Sequence_Gridcontrol(GridView _gridview, RowIndicatorCustomDrawEventArgs e)
        {
            //_gridview.IndicatorWidth = 30;
            if (e.RowHandle >= 0)
                e.Info.DisplayText = (e.RowHandle + 1).ToString();
        }
        public static void Create_Dataset_New5V//new 03-2022 with V = VIEW; A = Action
        (
              DataSet _dts_
            , DataTable _dt_name
            , string _sp_name
            , DevExpress.XtraGrid.GridControl _gridcontrol
            , GridView _gridview
            , NewItemRowPosition _PotitionNewRows
            , EditorShowMode _editshowmode
        )
        {
            bool _create_first = true;
            bool _create_second = true;
            //cho phép nhập row mới
            _gridview.ActiveFilter.Clear();
            DataTable dt = new DataTable();
            DataTable dt2 = new DataTable();
            DataTable dt_config = new DataTable();
            DataTable dt_freeze = new DataTable();
            dt_freeze.Columns.Add("Columname", typeof(string));

            bool show_field;
            //tạo ban đầu
            if (_create_first)
            {
                dt = Getgridconfig(2, _sp_name);
                dt2 = Getgridconfig(3, _sp_name);
                _dt_name.Columns.Clear();
                _gridview.Columns.Clear();
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    DataRow dr = dt.Rows[i];
                    Type type = Type.GetType(dr["DataType"].ToString());
                    DataColumnCollection columns = _dt_name.Columns;
                    if (!columns.Contains(dr["ColumnName"].ToString()))
                    {
                        _dt_name.Columns.Add(dr["ColumnName"].ToString(), typeof(Type));
                    }
                }
                _gridcontrol.DataSource = _dts_;// _dts_.Tables[_dt_name.ToString()];
                _gridcontrol.DataMember = _dt_name.ToString();
            }
            if (_create_second)
            {
                bool _showfooter = false;
                _showfooter = bool.Parse(dt2.Rows[0]["ShowFooter"].ToString());
                //xóa hết tất cả column đang có
                _gridview.Columns.Clear();
                //process data table config apply to column be created before
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //add freeze to list
                    DataRow dr = dt.Rows[i];
                    if (dr["Freeze"].ToString() == "1")
                    {
                        dt_freeze.Rows.Add(dr["ColumnName"].ToString());
                    }
                    GridColumn col = new GridColumn();
                    col.FieldName = dr["ColumnName"].ToString();
                    col.Name = dr["ColumnName"].ToString();
                    show_field = false;

                    col.Caption = dr["Caption"].ToString();
                    col.Width = int.Parse(dr["Width"].ToString());
                    col.OptionsColumn.AllowEdit = (dr["EditTable"].ToString() == "1") ? true : false;
                    col.OptionsColumn.AllowFocus = (dr["Allowfocus"].ToString() == "1") ? true : false;
                    show_field = (dr["SUDUNG"].ToString() == "1") ? true : false;

                    if (Left(dr["DataType"].ToString(), 4).ToUpper() != "DATE")
                    {
                        if (dr["DataType"].ToString() == "int" || dr["DataType"].ToString() == "double")
                        {
                            if (dr["AllowSeparate"].ToString() == "1")
                            {
                                col.DisplayFormat.FormatType = FormatType.Numeric;
                                col.DisplayFormat.FormatString = "N" + dr["DecimalChar"].ToString();// _formatstring;
                            }
                            //xử lý sum bên dưới grid nhưng cột kiểu số
                            if (_showfooter)
                            {
                                if (dr["AllowSumarize"].ToString() == "1")
                                {
                                    if (dr["FooterFunction"].ToString().ToUpper() == "SUM")
                                    {
                                        GridColumnSummaryItem columnformat;
                                        columnformat = col.Summary.Add(DevExpress.Data.SummaryItemType.Sum);
                                        columnformat.DisplayFormat = "{0:N" + dr["DecimalChar"].ToString() + "}";
                                    }
                                    else if (dr["FooterFunction"].ToString() == "COUNT")
                                    {
                                        GridColumnSummaryItem columnformat;
                                        columnformat = col.Summary.Add(DevExpress.Data.SummaryItemType.Count);
                                        columnformat.DisplayFormat = "Total current rows{0: = " + dr["DecimalChar"].ToString() + "}";
                                    }
                                    else if (dr["FooterFunction"].ToString() == "AVERAGE")
                                    {
                                        GridColumnSummaryItem columnformat;
                                        columnformat = col.Summary.Add(DevExpress.Data.SummaryItemType.Average);
                                        columnformat.DisplayFormat = "{0:N" + dr["DecimalChar"].ToString() + "}";
                                    }
                                    else if (dr["FooterFunction"].ToString() == "CUSTOM")
                                    {
                                        GridColumnSummaryItem columnformat;
                                        columnformat = col.Summary.Add(DevExpress.Data.SummaryItemType.Custom);
                                        columnformat.DisplayFormat = "{0:N" + dr["DecimalChar"].ToString() + "}";
                                    }
                                    else if (dr["FooterFunction"].ToString() == "MIN")
                                    {
                                        GridColumnSummaryItem columnformat;
                                        columnformat = col.Summary.Add(DevExpress.Data.SummaryItemType.Min);
                                        columnformat.DisplayFormat = "{0:N" + dr["DecimalChar"].ToString() + "}";
                                    }
                                    else if (dr["FooterFunction"].ToString() == "MAX")
                                    {
                                        GridColumnSummaryItem columnformat;
                                        columnformat = col.Summary.Add(DevExpress.Data.SummaryItemType.Max);
                                        columnformat.DisplayFormat = "{0:N" + dr["DecimalChar"].ToString() + "}";
                                    }
                                    else if (dr["FooterFunction"].ToString() == "NONE")
                                    {
                                        GridColumnSummaryItem columnformat;
                                        columnformat = col.Summary.Add(DevExpress.Data.SummaryItemType.None);
                                        columnformat.DisplayFormat = "{0:N" + dr["DecimalChar"].ToString() + "}";
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        string _format = _formatDate;
                        DevExpress.XtraEditors.Repository.RepositoryItemDateEdit dtpdateEdit = new RepositoryItemDateEdit();
                        ((System.ComponentModel.ISupportInitialize)(dtpdateEdit.CalendarTimeProperties)).EndInit();
                        ((System.ComponentModel.ISupportInitialize)(dtpdateEdit)).EndInit();
                        col.ColumnEdit = dtpdateEdit;
                        dtpdateEdit.AutoHeight = true;
                        dtpdateEdit.CalendarTimeProperties.Buttons.AddRange(new DevExpress.XtraEditors.Controls.EditorButton[] {
                                        new DevExpress.XtraEditors.Controls.EditorButton(DevExpress.XtraEditors.Controls.ButtonPredefines.Combo)});
                        dtpdateEdit.Name = "dpt" + col.FieldName.ToString();
                        dtpdateEdit.DisplayFormat.FormatString = _format;
                        dtpdateEdit.DisplayFormat.FormatType = DevExpress.Utils.FormatType.DateTime;
                        dtpdateEdit.EditFormat.FormatString = _format;
                        dtpdateEdit.EditFormat.FormatType = DevExpress.Utils.FormatType.DateTime;
                        dtpdateEdit.Mask.MaskType = DevExpress.XtraEditors.Mask.MaskType.DateTime;                       
                    }
                    //-------------------------------------------------------------------------------------------------------------------------------
                    _gridview.Columns.Add(col);
                    _gridview.Columns[i].Visible = show_field;                    
                }

                bool _columnautowidth = false;
                bool _showgrouppanel = false;
                bool _showfilter = false;
                bool _AllowColumnResizing = false;
                bool _AllowColumnMoving = false;
                bool _AllowFilter = false;
                bool _EnterMoveNextColumn = false;
                bool _multiselectrows = false;
                int _indicatorWidth = 0;
                bool _allowsort = false;

                _columnautowidth = bool.Parse(dt2.Rows[0]["ColumnAutoWidth"].ToString());
                _showgrouppanel = bool.Parse(dt2.Rows[0]["ShowGroupPanel"].ToString());
                _showfilter = bool.Parse(dt2.Rows[0]["ShowFilter"].ToString());
                _AllowColumnResizing = bool.Parse(dt2.Rows[0]["AllowColumnResizing"].ToString());
                _AllowColumnMoving = bool.Parse(dt2.Rows[0]["AllowColumnMoving"].ToString());
                _AllowFilter = bool.Parse(dt2.Rows[0]["AllowFilter"].ToString());
                _EnterMoveNextColumn = bool.Parse(dt2.Rows[0]["EnterMoveNextColumn"].ToString());
                _multiselectrows = bool.Parse(dt2.Rows[0]["MultiSelectRows"].ToString());
                _indicatorWidth = int.Parse(dt2.Rows[0]["IndicatorWidth"].ToString());
                _allowsort = bool.Parse(dt2.Rows[0]["AllowSort"].ToString());

                _gridview.IndicatorWidth = _indicatorWidth;
                _gridview.OptionsNavigation.EnterMoveNextColumn = _EnterMoveNextColumn;
                //-------------------------------------------------------------------------------------------------------------------------------
                _gridview.OptionsBehavior.AllowAddRows = DevExpress.Utils.DefaultBoolean.True;
                _gridview.OptionsBehavior.AllowDeleteRows = DevExpress.Utils.DefaultBoolean.True;
                _gridview.OptionsBehavior.EditingMode = DevExpress.XtraGrid.Views.Grid.GridEditingMode.Inplace;
                _gridview.OptionsBehavior.EditorShowMode = _editshowmode;//EditorShowMode.MouseDownFocused;
                //-------------------------------------------------------------------------------------------------------------------------------
                _gridview.OptionsCustomization.AllowColumnMoving = _AllowColumnMoving;
                _gridview.OptionsCustomization.AllowColumnResizing = _AllowColumnResizing;
                _gridview.OptionsCustomization.AllowFilter = _AllowFilter;
                _gridview.OptionsCustomization.AllowSort = _allowsort;
                //-------------------------------------------------------------------------------------------------------------------------------
                _gridview.OptionsView.ColumnAutoWidth = _columnautowidth;
                _gridview.OptionsView.NewItemRowPosition = _PotitionNewRows;
                _gridview.OptionsView.ShowAutoFilterRow = _showfilter;
                _gridview.OptionsView.ShowGroupPanel = _showgrouppanel;
                _gridview.OptionsView.ShowFooter = _showfooter;
                //-------------------------------------------------------------------------------------------------------------------------------
                _gridview.OptionsSelection.MultiSelect = _multiselectrows;
                _gridview.OptionsSelection.MultiSelectMode = GridMultiSelectMode.CheckBoxRowSelect;
                _gridview.OptionsSelection.CheckBoxSelectorColumnWidth = 20;
                _gridview.OptionsView.RowAutoHeight = true;
                _gridview.Appearance.FocusedRow.BackColor = Color.Green;                
                _gridview.Appearance.FocusedRow.Options.UseBackColor = true;                

                if (_multiselectrows)
                {
                    //_gridview.Columns[CheckboxSelectorColumn].Fixed = DevExpress.XtraGrid.Columns.FixedStyle.Left;
                    _gridview.VisibleColumns[0].Fixed = DevExpress.XtraGrid.Columns.FixedStyle.Left;
                }
                if (dt_freeze.Rows.Count > 0)
                {
                    for (int i = 0; i < dt_freeze.Rows.Count; i++)
                    {
                        string _columname = dt_freeze.Rows[i]["Columname"].ToString();
                        _gridview.Columns[_columname].Fixed = DevExpress.XtraGrid.Columns.FixedStyle.Left;
                    }
                }
            }
        }
        public static void ExportExcelFile_GridControl(DevExpress.XtraGrid.GridControl grid, string filename)
        {
            SaveFileDialog saveFileDialog = new SaveFileDialog();
            saveFileDialog.FileName = filename;
            saveFileDialog.Filter = "Excel files|*.xlsx";
            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                DataTable dt = new DataTable();
                grid.ExportToXlsx(saveFileDialog.FileName);
            }
        }
        public static void start_loading(string promt)
        {
            //Cls_HamTuTao_base cls_hamtutao = new Cls_HamTuTao_base();
            //cls_hamtutao.end_loading();
            SplashScreenManager.ShowDefaultSplashScreen("[Loreal VN]", (promt.Length > 0) ? promt : _promt);
        }
        public static void end_loading()
        {
            SplashScreenManager.CloseDefaultWaitForm();
        }
    }
}
