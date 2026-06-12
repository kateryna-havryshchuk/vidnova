using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Vidnova.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddDailyCheckInAiInsights : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DailyCheckInAiInsights",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Date = table.Column<DateOnly>(type: "date", nullable: false),
                    DailyCheckInId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    SourceUpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Model = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                    PromptText = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ResponseText = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DailyCheckInAiInsights", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DailyCheckInAiInsights_DailyCheckIns_DailyCheckInId",
                        column: x => x.DailyCheckInId,
                        principalTable: "DailyCheckIns",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DailyCheckInAiInsights_DailyCheckInId",
                table: "DailyCheckInAiInsights",
                column: "DailyCheckInId");

            migrationBuilder.CreateIndex(
                name: "IX_DailyCheckInAiInsights_UserId_Date",
                table: "DailyCheckInAiInsights",
                columns: new[] { "UserId", "Date" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DailyCheckInAiInsights");
        }
    }
}
