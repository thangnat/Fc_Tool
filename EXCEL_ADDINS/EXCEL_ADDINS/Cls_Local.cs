using System;
using System.IO;
using System.Linq;
using System.Data;
//using DevExpress.XtraEditors;
using System.Windows.Forms;
//using DevExpress.Data;
//using SAPConfig;
//using H2T_BaseSys;
using Microsoft.VisualBasic.FileIO;
//using Microsoft.VisualBasic.FileIO;

namespace EXCEL_ADDINS
{
    public class Cls_Local
    {
        //Cls_HamTuTao_base cls_hamtutao = new Cls_HamTuTao_base();
        //Cls_BaseSys cls_sys = new Cls_BaseSys();
        //SQLConnectionLog sqllog = new SQLConnectionLog();

        //extension file txt
        //public static string _Cls_Local_Msg_name = string.Empty;
        public static string _Cls_Local_Servername = "";
        public static string _Cls_Local_dbname = "SC2";
        //public static string _Cls_Local_password = "";
        public static string _ErrorMessage = "";
        public static bool _Cls_Local_ImportAuto = false;
        public static string _computername = "";
        public static string _Cls_local_UserID = "";
        public static string _Cls_local_password = "sgl789";
        public static bool _cls_local_Lsystem = false;        
        public bool IsFileLocked(string _filename)
        {
            bool _result = false;
            try
            {
                using (Stream stream = new FileStream(_filename, FileMode.Open))
                {
                    _result = false;
                    // File/Stream manipulating code here
                }
            }
            catch
            {
                _result = true;
                //check here why it failed and ask user to retry if the file is in use.
            }
            //file is not locked
            return _result;
        }
        public void getconfiglogin()
        {
            _computername = Environment.MachineName;
            var data = File
            .ReadAllLines(@"Extension\H2T.ini")
            .Select(x => x.Split('='))
            .Where(x => x.Length > 1)
            .ToDictionary(x => x[0].Trim(), x => x[1]);

            //_Cls_Local_Msg_name = data["ServerName"];
            _Cls_Local_Servername = data["ServerName"];
            _Cls_Local_Servername = data["SuerName"];
            //_Cls_Local_dbname = data["DataBase"];
            //_Cls_Local_ImportAuto = (data["ImportAuto"] == "1") ? true : false;
        }
        public bool ConnecttoServer()// string _userID)
        {
            bool connects1 = false;
            try
            {
                //if (_Cls_Local_ImportAuto)
                //{
                //    _userID = "sa";
                //    _cls_local_password = "Saigon@SQL2023";
                //}

                Program1.gsConnectionString = "Server=" + _Cls_Local_Servername + ";Database = " + _Cls_Local_dbname + ";User ID= " + _Cls_local_UserID + ";Password=" + _Cls_local_password + "";

                connects1 = ConnectDataBase();
                if (connects1)
                {
                    cls_sys.PhanHanh = Program1.gnPhanHanh;
                    cls_sys.Right = Program1.gsRight;
                    cls_sys.ConnectionString = Program1.gsConnectionString;
                    cls_sys.CnConnect = Program1.gcnConnect;
                    cls_sys.Account = Program1.gsAccount;
                    cls_sys.UserName = Program1.gsUserName;
                    cls_sys.SourcePath = Program1.gsSourcePath;
                    cls_sys.ApplicationPath = Program1.gsApplicationPath;
                    cls_sys.SanPhamPath = Program1.gsSanPhamPath;
                    cls_sys.GDate = Program1.gsDate;
                    cls_sys.GTime = Program1.gsTime;
                    cls_sys.UserID = Program1.gsUserID;
                    cls_sys.MaPB = Program1.gnMaPB;
                    cls_sys.gsCompanyCode = Program1.gsCompanyCode;
                    Program1.gsdbname = _Cls_Local_dbname;
                    Program1.gsServerName = _Cls_Local_Servername;
                }
                else
                {
                    _ErrorMessage = "Không vào được server...";
                    connects1 = false;
                    //XtraMessageBox.Show("Không vào được server: ", mod_BaseSys.gsCompanyCode, MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
            catch (Exception ex)
            {
                _ErrorMessage = ex.Message;
                connects1 = false;
            }
            return connects1;
        }
        public bool ConnectDataBase()
        {
            bool connects = false;
            try
            {
                if (Program1.gcnConnect.State == ConnectionState.Open)
                    Program1.gcnConnect.Close();
                Program1.gcnConnect.ConnectionString = Program1.gsConnectionString;
                Program1.gcnConnect.Open();
                connects = true;

                //if (mod_BaseSys.gcnConnect.State == ConnectionState.Open)
                //    mod_BaseSys.gcnConnect.Close();
                //mod_BaseSys.gcnConnect.ConnectionString = Program.gsConnectionString;
                //mod_BaseSys.gcnConnect.Open();
                //connects = true;
            }
            catch //(Exception ex)
            {
                // MessageBox.Show("Lỗi");
                connects = false;
            }
            return connects;
        }
        public DataTable GetDataTabletFromCSV_TXT_File(string csv_file_path, int _typeconvert)//1: normal, 2: special
        {
            DataTable csvData = new DataTable();
            try
            {
                using (TextFieldParser csvReader = new TextFieldParser(csv_file_path))
                {
                    csvReader.SetDelimiters(new string[] { "|" });
                    csvReader.HasFieldsEnclosedInQuotes = true;
                    string[] colFields = csvReader.ReadFields();
                    //DataColumn datecolumn1 = new DataColumn("Filename");
                    //datecolumn1.AllowDBNull = true;
                    //csvData.Columns.Add(datecolumn1);
                    foreach (string column in colFields)
                    {
                        if (_typeconvert == 1)
                        {
                            DataColumn datecolumn = new DataColumn(column);
                            datecolumn.AllowDBNull = true;
                            csvData.Columns.Add(datecolumn);
                        }
                        else
                        {
                            if (column == "LorealEAN")
                            {
                                DataColumn datecolumn1 = new DataColumn("Column1");
                                datecolumn1.AllowDBNull = true;
                                csvData.Columns.Add(datecolumn1);
                                DataColumn datecolumn2 = new DataColumn("LorealEAN");
                                datecolumn2.AllowDBNull = true;
                                csvData.Columns.Add(datecolumn2);
                            }
                            else
                            {
                                DataColumn datecolumn = new DataColumn(column);
                                datecolumn.AllowDBNull = true;
                                csvData.Columns.Add(datecolumn);
                            }
                        }
                    }
                    while (!csvReader.EndOfData)
                    {
                        string[] fieldData = csvReader.ReadFields();
                        //Making empty value as null
                        for (int i = 0; i < (fieldData.Length + 0); i++)
                        {
                            if (fieldData[i] == "")
                            {
                                fieldData[i] = null;
                            }
                        }

                        //csvData.Rows.Add(_filename_extension_date);
                        csvData.Rows.Add(fieldData);
                    }
                }
            }
            catch //(Exception ex)
            {
                //XtraMessageBox.Show(ex.Message,mod_BaseSys.gsCompanyCode,MessageBoxButtons.OK,MessageBoxIcon.Error);
                //error_ = ex.Message;
                //Return_InfoAction("Get data fail for this file: ", ex.Message + "=> [" + ((_typeconvert == 1) ? "Run normal" : "Run special") + "]");
                //richInfo.Text = richInfo.Text + "\n" + "Get data fail for this file: " + FileName_ + "\n Erorr detail: "+ex.Message;
                return null;
            }
            return csvData;
        }
        
        public void getdata_csv(string filename,string result)
        {
            DataTable csvFileData = new DataTable();
            csvFileData = GetDataTabletFromCSV_TXT_File(filename,1);// txtpathfile.Text.Replace("'", "''").Trim(), 1, tablename); // cbbTablename.Text);
            if (csvFileData.Rows.Count > 0)
            {
                result = csvFileData.Rows[0].ToString();
            }
            else
            {
                result = "";
            }
        }       
    }
}
