using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Vidnova.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FixAbcEvidencePrimaryKey : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_AbcEvidence",
                table: "AbcEvidence");

            migrationBuilder.AddColumn<Guid>(
                name: "Id",
                table: "AbcEvidence",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedDate",
                table: "AbcEvidence",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedDate",
                table: "AbcEvidence",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_AbcEvidence",
                table: "AbcEvidence",
                column: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_AbcEvidence",
                table: "AbcEvidence");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "AbcEvidence");

            migrationBuilder.DropColumn(
                name: "CreatedDate",
                table: "AbcEvidence");

            migrationBuilder.DropColumn(
                name: "UpdatedDate",
                table: "AbcEvidence");

            migrationBuilder.AddPrimaryKey(
                name: "PK_AbcEvidence",
                table: "AbcEvidence",
                column: "AbcEntryId");
        }
    }
}
