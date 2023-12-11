import {
  registerDecorator,
  ValidationArguments,
  ValidationOptions,
} from 'class-validator';

export function IsPriceCorrect(
  property: string,
  validationOptions?: ValidationOptions,
) {
  return (object, propertyName: string) => {
    registerDecorator({
      name: 'IsPriceCorrect',
      target: object.constructor,
      propertyName,
      options: { message: 'price is something wrong.', ...validationOptions },
      constraints: [property],
      validator: {
        validate(
          value: any,
          validationArguments?: ValidationArguments,
        ): Promise<boolean> | boolean {
          const [relatedPropertyName] = validationArguments.constraints;
          const relatedValue = (validationArguments.object as any)[
            relatedPropertyName
          ];
          if (
            (relatedValue === true && value !== null && value !== undefined) ||
            (relatedValue === false && (value === undefined || value === null))
          ) {
            return false;
          } else {
            if (relatedValue === true) {
              return true;
            } else {
              return typeof value === 'number';
            }
          }
        },
      },
    });
  };
}
