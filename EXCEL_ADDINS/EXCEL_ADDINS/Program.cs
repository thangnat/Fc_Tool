using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
//using H2T_BaseSys;
using System.Configuration;

namespace EXCEL_ADDINS
{
    public class Program
    {
        //SAPActive.SapConnection conn;
        public static int gnPhanHanh;
        //quyen su dung tren menu : "VIEW" va "UPDATE"
        public static string gsRight;
        public static string gsConnectionString;
        public static string gsConnectionString_admin = @"Data Source=10.240.65.33;Initial Catalog=SC2;User ID="+((gsUserID.Length ==0)?"sa":gsUserID)+";Password="+((gsUserID.Length==0)?"Saigon@SQL2023":"sgl789")+";Connect Timeout=3600000";
        public static SqlConnection gcnConnect_admin = new SqlConnection();
        public static SqlConnection gcnConnect = new SqlConnection();
        public static string gsAccount;
        //ho ten nguoi dang nhap
        public static string gsUserName;
        //id cua user tren SQLServer
        public static string gsUserID="";
        //path chua nguon tren server de load exe chuong trinh
        public static string gsSourcePath;
        //path chua hinh san pham tren server
        public static string gsSanPhamPath;
        //duong dan file exe tren may client
        public static string gsApplicationPath;
        //format : dd/mm/yyyy la ngay cua server
        public static string gsDate;
        //format : hh:mm:ss xxxx la gio tren server
        public static string gsTime;
        //ma phong ban
        public static int gnMaPB;
        public static string gsCompanyCode = "L'Oreal";
        //ma menu
        //public static string gsMenuCode;
        //ma quyen 
        public static string gsQuyenCode;
        //autorunDTTH
        public static int gsAutoRunDTTH;
        //isadmin
        public static int gsIsAdmin;
        //public static string _division;
        public static string ConfigSiteCode;
        public static string gsServerName;
        public static string gsDatabaseName;
        public static string gsNetworkName;
        public static string gsdbname;
        //public static string Accesspath = @"C:\phuongho\PROJECT\DESIGN\CSharp\FC\FC_Addins\EXCEL_ADDINS\bin\Debug\FC_SysData.mdb";
        public static string FC_Version_Guid = "5D636FD3-8106-4BE8-969D-44891479145C";
    }
}
