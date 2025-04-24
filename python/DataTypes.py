class Item:
    def __init__(self, name, price, description, link, rate, image_link=None, currency=None):
        self.name = name
        self.price = price
        self.description = description
        self.link = link
        self.rate = rate
        self.image_link = image_link
        self.currency = currency