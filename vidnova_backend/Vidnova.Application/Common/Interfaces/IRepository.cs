namespace Vidnova.Application.Common.Interfaces;

public interface IRepository<T> where T : class
{
    void Add(T entity);
    void Remove(T entity);
}

