from sqlalchemy import create_engine, Column, Integer, String, Boolean, UniqueConstraint, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship, backref, sessionmaker
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Company(Base):
    __tablename__ = 'company'
    company_id = Column(Integer, primary_key=True)
    company_name = Column(String(50))
    ceo = Column(String(50))
    office_address = Column(String(100))
    email = Column(String(100))

class Store(Base):
    __tablename__ = 'store'
    store_id = Column(Integer, primary_key=True)
    store_name = Column(String(50))
    store_address = Column(String(100), nullable=False)
    company_id = Column(Integer, ForeignKey('company.company_id'), nullable=False,
                        onupdate='CASCADE', ondelete='CASCADE')
    company = relationship(Company, backref=backref('stores', cascade='all, delete-orphan'))
    manager_id = Column(Integer, ForeignKey('manager.manager_id'), unique=True, nullable=False,
                        onupdate='CASCADE', ondelete='CASCADE')
    manager = relationship("Manager", backref=backref('store', uselist=False))

class Product(Base):
    __tablename__ = 'product'
    product_id = Column(Integer, primary_key=True)
    product_name = Column(String(50), nullable=False)
    product_type = Column(String(50), nullable=False)
    price = Column(Integer, nullable=False)

class StoreProduct(Base):
    __tablename__ = 'store_product'
    store_id = Column(Integer, ForeignKey('store.store_id'), primary_key=True,
                      onupdate='CASCADE', ondelete='CASCADE')
    product_id = Column(Integer, ForeignKey('product.product_id'), primary_key=True,
                        onupdate='CASCADE', ondelete='CASCADE')
    quantity = Column(Integer, nullable=False)
    store = relationship(Store, backref=backref('products', cascade='all, delete-orphan'))
    product = relationship(Product, backref=backref('stores', cascade='all, delete-orphan'))


class Manager(Base):
    __tablename__ = 'manager'
    manager_id = Column(Integer, primary_key=True)
    manager_name = Column(String(50), nullable=False)
    email = Column(String(50), nullable=False)
    salary = Column(Integer, nullable=False)

class ProductReplacement(Base):
    __tablename__ = 'product_replacement'
    __table_args__ = (
        UniqueConstraint('product_id', name='uq_product_id'),
        CheckConstraint('replacement_id != product_id', name='ck_replacement_id'),
        {'extend_existing': True}
    )
    
    product_id = Column(Integer, primary_key=True)
    replacement_id = Column(Integer, primary_key=True)
    
    product = relationship("Product", foreign_keys=[product_id], backref=backref('product_replacement', uselist=False))
    replacement = relationship("Product", foreign_keys=[replacement_id], backref=backref('replacement_product', uselist=False))


class ParkingSpace(Base):
    __tablename__ = 'parking_space'
    parking_space_id = Column(Integer, primary_key=True)
    invalid = Column(Boolean, nullable=False, default=False)

class ManagerParkingSpace(Base):
    __tablename__ = 'manager_parking_space'
    manager_id = Column(Integer, primary_key=True, nullable=False, unique=True)
    parking_space_id = Column(Integer, unique=True, nullable=False)
    manager = relationship("Manager", back_populates="parking_space", uselist=False,
                           cascade="save-update, merge, delete")
    parking_space = relationship("ParkingSpace", back_populates="manager", uselist=False,
                                 cascade="save-update, merge, delete")

Manager.parking_space = relationship("ManagerParkingSpace", uselist=False,
                                      cascade="save-update, merge, delete",
                                      back_populates="manager")
ParkingSpace.manager = relationship("ManagerParkingSpace", uselist=False,
                                     cascade="save-update, merge, delete",
                                     back_populates="parking_space")




engine = create_engine("postgresql://demo:demo@postgres:12345/demo")
Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)
