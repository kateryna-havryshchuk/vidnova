using Vidnova.Infrastructure.DependencyInjection;
using DotNetEnv;
using Microsoft.EntityFrameworkCore;
using Vidnova.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

var envPath = Path.GetFullPath(Path.Combine(builder.Environment.ContentRootPath, "..", "..", ".env"));
if (File.Exists(envPath))
{
    Env.Load(envPath);

    builder.Configuration.AddEnvironmentVariables();
}

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddInfrastructureServices(builder.Configuration);

var app = builder.Build();

//Перевірка з'єднання з БД
app.MapGet("/db-ping", async (AppDbContext dbContext) =>
{
    var canConnect = await dbContext.Database.CanConnectAsync();
    var database = dbContext.Database.GetDbConnection().Database;
    var datasource = dbContext.Database.GetDbConnection().DataSource;
    return Results.Ok(new
    {
        canConnect,
        database,
        datasource
    });
});

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.Run();
