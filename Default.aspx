<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<script runat="server">
    protected void Page_Load(object s, EventArgs e)
    {
        if (IsPostBack) return;
        txtDate.Text = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
        var st = Db.Table("SELECT Source AS S FROM Trains UNION SELECT Destination FROM Trains ORDER BY S");
        ddlFrom.DataSource = st; ddlFrom.DataTextField = "S"; ddlFrom.DataBind();
        ddlTo.DataSource = st; ddlTo.DataTextField = "S"; ddlTo.DataBind();
    }
    protected void btnSearch_Click(object s, EventArgs e)
    {
        Session["date"] = txtDate.Text;
        gv.DataSource = Db.Table("SELECT * FROM Trains WHERE Source=@a AND Destination=@b",
            Db.P("@a", ddlFrom.SelectedValue), Db.P("@b", ddlTo.SelectedValue));
        gv.DataBind();
        lblMsg.Text = gv.Rows.Count == 0 ? "No trains found for this route." : "";
    }
</script>
<asp:Content ContentPlaceHolderID="body" runat="server">
  <div class="card shadow-sm p-4 mb-4">
    <h4>Search Trains</h4>
    <div class="row g-3">
      <div class="col-md-3"><label>From</label><asp:DropDownList ID="ddlFrom" runat="server" CssClass="form-select" /></div>
      <div class="col-md-3"><label>To</label><asp:DropDownList ID="ddlTo" runat="server" CssClass="form-select" /></div>
      <div class="col-md-3"><label>Date</label><asp:TextBox ID="txtDate" runat="server" TextMode="Date" CssClass="form-control" /></div>
      <div class="col-md-3 d-flex align-items-end"><asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary w-100" OnClick="btnSearch_Click" /></div>
    </div>
  </div>
  <asp:Label ID="lblMsg" runat="server" CssClass="text-danger" />
  <asp:GridView ID="gv" runat="server" AutoGenerateColumns="false" CssClass="table table-striped bg-white" GridLines="None">
    <Columns>
      <asp:BoundField DataField="TrainNo" HeaderText="Train No" />
      <asp:BoundField DataField="TrainName" HeaderText="Train" />
      <asp:BoundField DataField="DepTime" HeaderText="Departs" />
      <asp:BoundField DataField="ArrTime" HeaderText="Arrives" />
      <asp:BoundField DataField="BaseFare" HeaderText="Fare (SL) ₹" DataFormatString="{0:N0}" />
      <asp:HyperLinkField Text="Book Now" DataNavigateUrlFields="TrainNo" DataNavigateUrlFormatString="Book.aspx?train={0}" ControlStyle-CssClass="btn btn-success btn-sm" />
    </Columns>
  </asp:GridView>
</asp:Content>
