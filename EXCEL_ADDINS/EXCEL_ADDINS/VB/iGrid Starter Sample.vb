Public Class FormStarterSample
    Private Sub FormStarterSample_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        With iGrid1
            ' Create a grid with 2 columns and 5 rows
            .Cols.Count = 2
            .Rows.Count = 5

            ' Set column captions
            .Cols(0).Text = "Column 1"
            .Cols(1).Text = "Column 2"

            ' Set some values in the first 2 cells in the first column
            .Cells(0, 0).Value = "abc"
            .Cells(1, 0).Value = 123

            ' The first cell in the second column will display
            ' the current date in red using the long date pattern
            With .Cells(0, 1)
                .Value = DateTime.Now
                .FormatString = "{0:D}"
                .ForeColor = Color.Red
            End With

            ' Automatically adjust the width of the second column
            ' to display its contents without clipping
            .Cols(1).AutoWidth()
        End With
    End Sub
End Class
