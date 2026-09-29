<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<script runat="server">
    static readonly string[] Cls = { "SL", "3A", "2A", "1A" };
    static readonly decimal[] Mult = { 1m, 2.5m, 3.5m, 6m };
    System.Data.DataRow Train;
    protected void Page_Load(object s, EventArgs e)
    {
        int no; int.TryParse(Request.QueryString["train"], out no);
        var t = Db.Table("SELECT * FROM Trains WHERE TrainNo=@n", Db.P("@n", no));
        if (t.Rows.Count == 0) { Response.Redirect("Default.aspx"); return; }
        Train = t.Rows[0];
        string d = Session["date"] as string ?? DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
        lblTrain.Text = Train["TrainNo"] + " - " + Train["TrainName"] + " (" + Train["Source"] + " → " + Train["Destination"] + ") on " + d;
        if (!IsPostBack)
        {
            for (int i = 0; i < 4; i++) ddlClass.Items.Add(new ListItem(Cls[i] + " - ₹" + ((decimal)Train["BaseFare"] * Mult[i]).ToString("N0"), Cls[i]));
            rp.DataSource = new int[4]; rp.DataBind();
        }
    }
    protected void btnBook_Click(object s, EventArgs e)
    {
        if (Session["UserId"] == null) { Response.Redirect("Login.aspx?ret=" + Server.UrlEncode(Request.RawUrl)); return; }
        var list = new System.Collections.Generic.List<string[]>();
        foreach (RepeaterItem it in rp.Items)
        {
            string n = ((TextBox)it.FindControl("n")).Text.Trim(), a = ((TextBox)it.FindControl("a")).Text.Trim();
            int age;
            if (n != "" && int.TryParse(a, out age) && age > 0 && age < 120)
                list.Add(new[] { n, a, ((DropDownList)it.FindControl("g")).SelectedValue });
        }
        if (list.Count == 0) { lblMsg.Text = "Enter at least one passenger with valid age."; return; }
        DateTime date = DateTime.Parse(Session["date"] as string ?? DateTime.Today.AddDays(1).ToString("yyyy-MM-dd"));
        int tno = (int)Train["TrainNo"], cap = (int)Train["Seats"];
        string cls = ddlClass.SelectedValue;
        decimal fare = (decimal)Train["BaseFare"] * Mult[Array.IndexOf(Cls, cls)] * list.Count;
        int booked = (int)Db.Scalar("SELECT COUNT(*) FROM Passengers p JOIN Bookings b ON b.PNR=p.PNR WHERE b.TrainNo=@t AND b.JourneyDate=@d AND b.Class=@c AND b.Status<>'CANCELLED'",
            Db.P("@t", tno), Db.P("@d", date), Db.P("@c", cls));
        string status = booked + list.Count <= cap ? "CONFIRMED" : "WAITLIST";
        long pnr = Convert.ToInt64(Db.Scalar("INSERT Bookings(UserId,TrainNo,JourneyDate,Class,TotalFare,Status) VALUES(@u,@t,@d,@c,@f,@s); SELECT SCOPE_IDENTITY();",
            Db.P("@u", Session["UserId"]), Db.P("@t", tno), Db.P("@d", date), Db.P("@c", cls), Db.P("@f", fare), Db.P("@s", status)));
        for (int i = 0; i < list.Count; i++)
        {
            int n = booked + i + 1;
            string seat = status == "CONFIRMED" ? cls + "-" + n : "WL/" + (n - cap);
            Db.Exec("INSERT Passengers(PNR,Name,Age,Gender,SeatNo) VALUES(@p,@n,@a,@g,@s)", Db.P("@p", pnr), Db.P("@n", list[i][0]), Db.P("@a", list[i][1]), Db.P("@g", list[i][2]), Db.P("@s", seat));
        }
        Response.Redirect("Pnr.aspx?pnr=" + pnr);
    }
</script>
<asp:Content ContentPlaceHolderID="body" runat="server">
  <div class="card p-4 shadow-sm">
    <h4>Book Ticket</h4>
    <p class="text-muted"><asp:Label ID="lblTrain" runat="server" /></p>
    <div class="col-md-4 mb-3"><label>Class</label><asp:DropDownList ID="ddlClass" runat="server" CssClass="form-select" /></div>
    <h6>Passengers (max 4)</h6>
    <asp:Repeater ID="rp" runat="server"><ItemTemplate>
      <div class="row g-2 mb-2">
        <div class="col-md-5"><asp:TextBox ID="n" runat="server" CssClass="form-control" placeholder="Name" /></div>
        <div class="col-md-3"><asp:TextBox ID="a" runat="server" TextMode="Number" CssClass="form-control" placeholder="Age" /></div>
        <div class="col-md-4"><asp:DropDownList ID="g" runat="server" CssClass="form-select"><asp:ListItem>Male</asp:ListItem><asp:ListItem>Female</asp:ListItem><asp:ListItem>Other</asp:ListItem></asp:DropDownList></div>
      </div></ItemTemplate></asp:Repeater>
    <asp:Label ID="lblMsg" runat="server" CssClass="text-danger" />
    <div><asp:Button ID="btnBook" runat="server" Text="Confirm Booking" CssClass="btn btn-success mt-2" OnClick="btnBook_Click" /></div>
  </div>
</asp:Content>
