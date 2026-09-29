<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<script runat="server">
    protected void Page_Load(object s, EventArgs e)
    {
        if (!IsPostBack && !string.IsNullOrEmpty(Request.QueryString["pnr"])) { txtPnr.Text = Request.QueryString["pnr"]; Show(); }
    }
    void Show()
    {
        long pnr;
        if (!long.TryParse(txtPnr.Text.Trim(), out pnr)) { lblMsg.Text = "Enter a valid PNR."; pnlResult.Visible = false; return; }
        var b = Db.Table(@"SELECT b.*, t.TrainName, t.Source, t.Destination, t.DepTime FROM Bookings b JOIN Trains t ON t.TrainNo=b.TrainNo WHERE b.PNR=@p", Db.P("@p", pnr));
        if (b.Rows.Count == 0) { lblMsg.Text = "PNR not found."; pnlResult.Visible = false; return; }
        var r = b.Rows[0]; lblMsg.Text = "";
        lblInfo.Text = string.Format("<b>{0} - {1}</b><br/>{2} → {3} | {4:dd MMM yyyy} {5} | Class {6}<br/>Fare: ₹{7:N0} | Status: <b>{8}</b>",
            r["TrainNo"], r["TrainName"], r["Source"], r["Destination"], r["JourneyDate"], r["DepTime"], r["Class"], r["TotalFare"], r["Status"]);
        gv.DataSource = Db.Table("SELECT Name,Age,Gender,SeatNo FROM Passengers WHERE PNR=@p", Db.P("@p", pnr)); gv.DataBind();
        bool mine = Session["UserId"] != null && Convert.ToInt32(r["UserId"]) == Convert.ToInt32(Session["UserId"]);
        btnCancel.Visible = mine && r["Status"].ToString() != "CANCELLED";
        pnlResult.Visible = true;
    }
    protected void btnCheck_Click(object s, EventArgs e) { Show(); }
    protected void btnCancel_Click(object s, EventArgs e)
    {
        Db.Exec("UPDATE Bookings SET Status='CANCELLED' WHERE PNR=@p AND UserId=@u", Db.P("@p", txtPnr.Text.Trim()), Db.P("@u", Session["UserId"]));
        Show();
    }
</script>
<asp:Content ContentPlaceHolderID="body" runat="server">
  <div class="card p-4 shadow-sm">
    <h4>PNR Status</h4>
    <div class="input-group mb-3 col-md-6" style="max-width:480px">
      <asp:TextBox ID="txtPnr" runat="server" CssClass="form-control" placeholder="Enter 10-digit PNR" />
      <asp:Button ID="btnCheck" runat="server" Text="Check" CssClass="btn btn-primary" OnClick="btnCheck_Click" />
    </div>
    <asp:Label ID="lblMsg" runat="server" CssClass="text-danger" />
    <asp:Panel ID="pnlResult" runat="server" Visible="false">
      <div class="alert alert-info"><asp:Label ID="lblInfo" runat="server" /></div>
      <asp:GridView ID="gv" runat="server" CssClass="table table-bordered bg-white" GridLines="None" />
      <asp:Button ID="btnCancel" runat="server" Text="Cancel Ticket" CssClass="btn btn-danger" OnClick="btnCancel_Click" OnClientClick="return confirm('Cancel this ticket?');" />
    </asp:Panel>
  </div>
</asp:Content>
