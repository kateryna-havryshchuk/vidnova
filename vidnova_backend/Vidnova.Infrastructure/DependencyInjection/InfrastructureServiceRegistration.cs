using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Infrastructure.Persistence;

namespace Vidnova.Infrastructure.DependencyInjection;

public static class InfrastructureServiceRegistration
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = $"Server={configuration["DB_SERVER"]},{configuration["DB_PORT"]};" +
                               $"Database={configuration["DB_NAME"]};" +
                               $"User Id={configuration["DB_USER"]};" +
                               $"Password={configuration["DB_PASSWORD"]};" +
                               "TrustServerCertificate=True;Encrypt=False;MultipleActiveResultSets=True;";
        
        services.AddDbContext<AppDbContext>(options => 
            options.UseSqlServer(connectionString,
                b => b.MigrationsAssembly(typeof(AppDbContext).Assembly.FullName)));

        services.AddScoped<IAppDbContext>(sp => sp.GetRequiredService<AppDbContext>());
        return services;
    }
}