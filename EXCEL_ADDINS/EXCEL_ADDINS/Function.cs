using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EXCEL_ADDINS
{
    public class Function
    {
        //public static string DBPath = Program.Accesspath;
        Cls_BaseSys cls_sys = new Cls_BaseSys();
        //public void BulkExportToAccess(string _sp_name,string _tableName, DataTable _dtOutData)
        //{
        //    /*
        //     ArrayList array_param = new ArrayList() { "@Division", "@Channel", "@Period" };
        //    ArrayList array_value = new ArrayList() { "CPD", "", "" };
        //    //DataTable _dtOutData = new DataTable();

        //    _dtOutData = cls_sys.Exec_StoreProc_datatable(_sp_name, array_param, array_value);
        //     */
        //    Connection_Access.ChangeCSDL_Access(@"Delete from "+_tableName);
        //    //DataTable dtOutData = null;
            
        //    //string TableNm = "SellIn";
        //    Microsoft.Office.Interop.Access.Dao.DBEngine dbEngine = new Microsoft.Office.Interop.Access.Dao.DBEngine();
        //    Boolean CheckFl = false;

        //    try
        //    {
        //        Microsoft.Office.Interop.Access.Dao.Database db = dbEngine.OpenDatabase(DBPath);
        //        Microsoft.Office.Interop.Access.Dao.Recordset AccesssRecordset = db.OpenRecordset(_tableName);
        //        Microsoft.Office.Interop.Access.Dao.Field[] AccesssFields = new Microsoft.Office.Interop.Access.Dao.Field[_dtOutData.Columns.Count];

        //        //Loop on each row of dtOutData
        //        for (Int32 rowCounter = 0; rowCounter < _dtOutData.Rows.Count; rowCounter++)
        //        {
        //            AccesssRecordset.AddNew();
        //            //Loop on column
        //            for (Int32 colCounter = 0; colCounter < _dtOutData.Columns.Count; colCounter++)
        //            {
        //                // for the first time... setup the field name.
        //                if (!CheckFl)
        //                    AccesssFields[colCounter] = AccesssRecordset.Fields[_dtOutData.Columns[colCounter].ColumnName.Replace(".", "").Replace(" ", "").Replace("-", "")];
        //                AccesssFields[colCounter].Value = _dtOutData.Rows[rowCounter][colCounter];
        //            }

        //            AccesssRecordset.Update();
        //            CheckFl = true;
        //        }

        //        AccesssRecordset.Close();
        //        db.Close();
        //    }
        //    finally
        //    {
        //        System.Runtime.InteropServices.Marshal.ReleaseComObject(dbEngine);
        //        dbEngine = null;
        //    }
        //}
    }
}
